;;; 35-cfg.el --- cfg macro, inspired by setup.el -*- lexical-binding: t; -*-

(defvar cfg-opts `((quit . ,(make-symbol "cfg-quit"))))
(defvar cfg-attributes '())
(defvar cfg-macros nil)

(defun cfg-get (opt)
  "Retrieve context value for OPT."
  (or (cdr (assq opt cfg-opts))
      (error "Cannot deduce %S from context" opt)))

(defun cfg-expand (body)
  "Expand cfg macros in BODY."
  (macroexpand-all (macroexp-progn body) cfg-macros))

(defmacro cfg-bind (body &rest vars)
  "Expand BODY with VARS bound in cfg context."
  (declare (indent 1))
  `(let ((cfg-opts (append
                      (list ,@(mapcar (lambda (b) `(cons ',(car b) ,(cadr b))) vars))
                      cfg-opts)))
     (cfg-expand ,body)))

(defun cfg-quit (&optional return)
  "Generate code to abort the current cfg body."
  (push 'need-quit cfg-attributes)
  `(throw ',(cfg-get 'quit) ,return))

(defun cfg-define (name fn &rest opts)
  "Define cfg-local macro NAME with FN."
  (declare (indent 1))
  (put name 'cfg-shorthand (plist-get opts :shorthand))
  (when-let* ((indent (plist-get opts :indent)))
    (put name 'lisp-indent-function indent))
  (let* ((rep (plist-get opts :repeatable))
         (n (and rep (if (eq rep t) (car (func-arity fn)) rep)))
         (fn (if n (lambda (&rest args)
                     (let (res)
                       (while args
                         (push (apply fn (seq-take args n)) res)
                         (setq args (seq-drop args n)))
                       (macroexp-progn (nreverse res))))
               fn))
         (fn (if (plist-get opts :after-loaded)
                 (lambda (&rest args)
                   `(with-eval-after-load ',(cfg-get 'feature)
                      ,(apply fn args)))
               fn)))
    (setf (alist-get name cfg-macros) fn)))


;;; Macros

(defmacro cfg (name &rest body)
  "Configure feature or subsystem NAME."
  (declare (indent 1))
  (when (consp name)
    (push name body)
    (let ((shorthand (get (car name) 'cfg-shorthand)))
      (setq name (and shorthand (funcall shorthand name)))))
  (let ((cfg-attributes cfg-attributes)
        (cfg-opts (append
                     (when name
                       (let ((mode (if (string-match-p "-mode\\'" (symbol-name name))
                                       name
                                     (intern (format "%s-mode" name)))))
                         `((feature . ,name) (mode . ,mode) (func . ,mode)
                           (hook . ,(intern (format "%s-hook" mode)))
                           (map . ,(intern (format "%s-map" mode))))))
                     cfg-opts)))
    (setq body (macroexpand-all
                (macroexp-progn body)
                (append cfg-macros macroexpand-all-environment)))
    (when (memq 'need-quit cfg-attributes)
      (setq body `(catch ',(cfg-get 'quit) ,@(macroexp-unprogn body))))
    body))

;;; Helpers

(defun cfg--add-hook-transient (hook fn)
  "Add FN to HOOK; FN removes itself after its first run."
  (let ((sym (make-symbol "cfg--transient")))
    (fset sym (lambda (&rest args)
               (remove-hook hook sym)
               (apply fn args)))
    (add-hook hook sym)))

(defun cfg--extract-depth (form)
  "Return (DEPTH . FORM). DEPTH is nil when unspecified."
  (if (and (consp form) (integerp (car form)))
      (cons (car form) (cadr form))
    (cons nil form)))

(defun cfg--transform-hook (hook)
  "Derive hook symbol, appending -hook to mode names."
  (if (string-suffix-p "-mode" (symbol-name hook))
      (intern (concat (symbol-name hook) "-hook"))
    hook))

(defun cfg--require-feat (sexp)
  "Extract feature from :require SEXP."
  (let ((arg (cadr sexp)))
    (if-let* (((consp arg))
              (sh (get (car arg) 'cfg-shorthand)))
        (funcall sh arg)
      arg)))

;;; Keywords — loading

(cfg-define :require
  (lambda (feature)
    `(require ',(cfg--require-feat (list :require feature))))
  :shorthand #'cfg--require-feat
  :repeatable t)

(cfg-define :if
  (lambda (condition) `(unless ,condition ,(cfg-quit)))
  :repeatable t)

(cfg-define :after
  (lambda (feats &rest body)
    (let ((result (macroexp-progn body)))
      (cond
       ((symbolp feats)
        `(with-eval-after-load ',feats ,result))
       ((eq (car-safe feats) 'quote)
        `(with-eval-after-load ,feats ,result))
       ((and (listp feats) (seq-every-p #'symbolp feats))
        (dolist (f (reverse feats)) (setq result `(with-eval-after-load ',f ,result)))
        result)
       ((and (listp feats) (seq-every-p #'listp feats))
        (dolist (f (reverse feats)) (setq result `(with-eval-after-load ,f ,result)))
        result)
       (t `(with-eval-after-load ,feats ,result)))))
  :indent 1)

(cfg-define :after-this
  (lambda (&rest body) (macroexp-progn body))
  :after-loaded t :indent 0)

;;; Keywords — hooks

(cfg-define :hook
  (lambda (function)
    (let ((d (cfg--extract-depth function)))
      `(add-hook ',(cfg-get 'hook) ,(cdr d) ,@(when (car d) (list (car d))))))
  :repeatable t)

(cfg-define :hook-to
  (lambda (hook &rest functions)
    (macroexp-progn
     (mapcar (lambda (function)
               (let ((d (cfg--extract-depth function)))
                 `(dolist (h (ensure-list ,hook))
                    (add-hook (cfg--transform-hook h) ,(cdr d)
                              ,@(when (car d) (list (car d)))))))
             functions)))
  :indent 1)

(cfg-define :hook-into
  (lambda (mode)
    (let ((d (cfg--extract-depth mode)))
      (setq mode (cdr d))
      `(add-hook ',(let ((name (symbol-name mode)))
                     (if (string-match-p "-hook\\'" name) mode
                       (intern (concat name "-hook"))))
                 #',(cfg-get 'func)
                 ,@(when (car d) (list (car d))))))
  :repeatable t)

(cfg-define :hook-transient
  (lambda (hook fn)
    `(cfg--add-hook-transient ,(if (symbolp hook) `',hook hook) ,fn))
  :repeatable t)

(cfg-define :unhook
  (lambda (func) `(remove-hook ',(cfg-get 'hook) ,func))
  :repeatable t)

(cfg-define :unhook-to
  (lambda (hook function)
    `(dolist (h (ensure-list ,hook))
       (remove-hook (cfg--transform-hook h) ,function)))
  :repeatable t :indent 1)

(cfg-define :unhook-into
  (lambda (mode)
    `(remove-hook ',(let ((name (symbol-name mode)))
                      (if (string-match-p "-hook\\'" name) mode
                        (intern (concat name "-hook"))))
                  #',(cfg-get 'func)))
  :repeatable t)

;;; Keywords — setters

(let ((get (lambda (name) `(funcall (or (get ',name 'custom-get) #'symbol-value) ',name)))
      (set (lambda (name val)
             `(progn (custom-load-symbol ',name)
                     (funcall (or (get ',name 'custom-set) #'set-default) ',name ,val)))))

  (cfg-define :opt
    (lambda (name val) (funcall set name val))
    :repeatable t)

  (cfg-define :append
    (lambda (name val)
      (let ((s (make-symbol "s")))
        (funcall set name
                 `(let ((,s ,val) (l ,(funcall get name)))
                    (if (member ,s l) l (append l (list ,s)))))))
    :repeatable t)

  (cfg-define :prepend
    (lambda (name val)
      (let ((s (make-symbol "s")))
        (funcall set name
                 `(let ((,s ,val) (l ,(funcall get name)))
                    (if (member ,s l) l (cons ,s l))))))
    :repeatable t)

  (cfg-define :append*
    (lambda (name val)
      (let ((s (make-symbol "s")))
        (funcall set name
                 `(let ((l ,(funcall get name)) ,s)
                    (dolist (i ,val) (unless (member i l) (push i ,s)))
                    (append l (nreverse ,s))))))
    :repeatable t)

  (cfg-define :prepend*
    (lambda (name val)
      (let ((s (make-symbol "s")))
        (funcall set name
                 `(let ((l ,(funcall get name)) ,s)
                    (dolist (i ,val) (unless (member i l) (push i ,s)))
                    (append (nreverse ,s) l)))))
    :repeatable t)

  (cfg-define :remove
    (lambda (name val)
      (funcall set name `(remove ,val ,(funcall get name))))
    :repeatable t)

  (cfg-define :remove*
    (lambda (name val)
      (funcall set name
               `(let ((l ,(funcall get name)))
                  (dolist (i ,val) (setq l (remove i l))) l)))
    :repeatable t))

(cfg-define :alias
  (lambda (name val) `(defalias ',name ,val))
  :repeatable t)

(cfg-define :local
  (lambda (name val) `(setq-local ,name ,val))
  :repeatable t)

(cfg-define :safe-local
  (lambda (sym) `(put ,sym 'safe-local-variable #'always))
  :repeatable t)

;;; Keywords — advice

(cfg-define :advice
  (lambda (where function)
    (let ((d (cfg--extract-depth function)))
      `(advice-add #',(cfg-get 'func) ,where ,(cdr d)
                   ,@(when (car d) `('((depth . ,(car d))))))))
  :repeatable t :indent 1)

(cfg-define :advice-to
  (lambda (to where function)
    (let ((d (cfg--extract-depth function)))
      `(dolist (place (ensure-list ,to))
         (advice-add place ,where ,(cdr d)
                     ,@(when (car d) `('((depth . ,(car d)))))))))
  :repeatable t :indent 2)

(cfg-define :unadvice-to
  (lambda (to _where function)
    `(dolist (place (ensure-list ,to)) (advice-remove place ,function)))
  :repeatable t :indent 2)

;;; Keywords — misc

(cfg-define :face
  (lambda (face spec) `(set-face-attribute ',face nil ,@spec))
  :repeatable t :after-loaded t)

(cfg-define :autoload
  (lambda (fn)
    (let ((fn (if (eq (car-safe fn) 'function) (cadr fn) fn)))
      `(autoload #',fn ,(symbol-name (cfg-get 'feature)))))
  :repeatable t)

;;; Keywords — filesystem

(cfg-define :join
  (lambda (&rest components)
    `(file-name-concat ,@components)))

(cfg-define :join-d
  (lambda (&rest components)
    `(file-name-as-directory (file-name-concat ,@components))))

(cfg-define :mkdir
  (lambda (&rest components)
    `(let ((path (file-name-concat ,@components)))
       (make-directory path t)
       path)))

(cfg-define :touch
  (lambda (&rest components)
    `(let ((path (file-name-concat ,@components)))
       (if (file-exists-p path)
           (set-file-times path)
         (write-region "" nil path nil 'silent))
       path)))

;;; Elpaca integration

(cfg-define :elpaca (lambda (&rest _) nil) :shorthand #'cadr)

(defun cfg-pkg--order (name)
  "Extract elpaca order from cfg-pkg NAME."
  (cond
   ((symbolp name) name)
   ((eq (car name) :elpaca) (cdr name))
   (t (or (when-let* ((found (seq-find (lambda (x) (and (consp x) (eq (car x) :elpaca)))
                                       (cdr name))))
            (cdr found))
          (when-let* ((sh (get (car name) 'cfg-shorthand)))
            (funcall sh name))))))

(defmacro cfg-pkg (name &rest body)
  "Configure package NAME with elpaca."
  (declare (indent 1))
  `(elpaca ,(cfg-pkg--order name) (cfg ,name ,@body)))

(provide 'cfg)
