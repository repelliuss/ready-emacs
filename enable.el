;;; enable.el -*- lexical-binding: t; -*-

;; FIXME: defaults indents one space in call to enable
;; TODO: add support to group by directories
;; TODO: make it quiet
;; TODO: switch to enable-using-eval after first call to cache, be careful about two seperate calls

(defgroup enable nil
  "A configuration manager."
  :group 'convenience
  :prefix "enable-")

;; TODO: handle nil
(defcustom enable-dir (concat user-emacs-directory "enable/")
  "Storage."
  :type 'file)

(defcustom enable-modules-dir (concat enable-dir "modules/")
  "Where modules should be looked for."
  :type 'file)

;; FIXME: doesn't create dir
(defcustom enable-cache-dir (concat enable-dir "cache/")
  "Where cache files are stored."
  :type 'file)

(defcustom enable-loader #'enable-using-eval
  "Load style of enable."
  :type #'function)

(defvar enable--cache-file (concat enable-cache-dir "enable-cache.el"))
(defvar enable--cache-state-file (concat enable-cache-dir "enable-cache-state.el"))
(defvar enable--early-cache-file (concat enable-cache-dir "enable-early-cache.el"))
(defvar enable--early-cache-state-file (concat enable-cache-dir "enable-early-cache-state.el"))

(defun enable--get-files (&optional path)
  (directory-files (concat enable-modules-dir path)
                   nil directory-files-no-dot-files-regexp))

(defvar enable--modules (mapcar (lambda (module-name)
                                  (intern (concat ":" (file-name-sans-extension module-name))))
				(enable--get-files)))

(defun enable--build (module files &optional packages-p)
  (let* ((module-path (concat enable-modules-dir (substring (symbol-name module) 1) "/"))
         (path (concat module-path (if packages-p "packages/" "submodules/"))))
    (dolist (file files)
      (funcall enable-loader (concat path
                                     (if (symbolp file)
                                         (symbol-name file)
                                       file)
                                     ".el")))))

(defun enable--build-module (module)
  (let ((pkg-defaults (intern (concat "enable--"
                                      (substring (symbol-name module) 1)
                                      "-pkg-defaults"))))
    (when (boundp pkg-defaults)
      (enable--build module
                     (eval pkg-defaults)
                     'packages)))
  (enable--build module
                 (eval (intern (concat "enable--"
                                       (substring (symbol-name module) 1)
                                       "-sub-all")))))

(defun enable--build-all ()
  (dolist (module enable--modules)
    (enable--build-module module)))

;; TODO: add support for package-name* -suffix +suffix feat
(defun enable--modify-list (var modifications)
  (mapc (lambda (subarg)
          (cond
           ((char-equal ?- (elt (symbol-name subarg) 0))
            (setq var (delq (intern (substring (symbol-name subarg) 1))
                            var)))
           (t ; (char-equal ?+ (elt (symbol-name subarg) 0))
            (push (make-symbol (symbol-name subarg) ;; (substring (symbol-name subarg) 1)
			       )
                  var))))
        modifications)
  var)

(defmacro enable--process (args)
  (let* (sexps
         (add-sexp (lambda (builder)
                     (setq sexps (nconc sexps (list builder))))))
    (cond ((eq 'all (car args)) '(enable--build-all))
          ((not (memq (car args) enable--modules))
           (error "No module name given to `enable'"))
          (t (let (module
                   (expr (car args))
                   (args (cdr args)))
               (while expr
                 (cond
                  ((memq expr enable--modules)
                   (setq module expr)
                   (when (eq 'all (car args))
                     (funcall add-sexp
                              `(enable--build-module ,module))
                     (setq args (cdr args))))
                  ((eq expr :sub)
                   (if (not (listp (car args)))
                       (error "`:sub' arg is not a list for `%s' in `enable'"
                              module)
                     (if (not (eq 'all (caar args)))
                         (funcall add-sexp
                                  `(enable--build ,module
                                                  ',(car args)))
                       (let ((sub-all (eval (intern (concat "enable--"
                                                            (substring (symbol-name module) 1)
                                                            "-sub-all")))))
                         (funcall add-sexp `(enable--build ,module
                                                           ',(enable--modify-list sub-all (cdar args)))))
                       (setq args (cdr args)))))
                  ((eq expr :pkg)
                   (if (not (listp (car args)))
                       (error "`:pkg' arg is not a list for `%s' in `enable'" module)
                     (if (not (eq 'defaults (caar args)))
                         (funcall add-sexp `(enable--build ,module ',(car args) 'packages))
                       (let ((pkg-defaults (eval (intern (concat "enable--"
                                                                 (substring (symbol-name module) 1)
                                                                 "-pkg-defaults")))))
                         (funcall add-sexp `(enable--build ,module
                                                           ',(enable--modify-list pkg-defaults (cdar args))
                                                           'packages)))
                       (setq args (cdr args))))))
                 (setq expr (car args)
                       args (cdr args))))))
    sexps))

(defmacro enable--with-cache (cache-file state-file args)
  (let* (load-list)
    (with-current-buffer (find-file-noselect state-file nil 'literal)
      (unless (and (file-exists-p cache-file)
                   (equal args (ignore-errors (read (current-buffer)))))
        (erase-buffer)
        (print args (current-buffer))
        (save-buffer)
        (delete-file cache-file)
        (setq load-list (nconc (macroexpand `(enable--process ,args)) `((save-buffer)))))
      (kill-buffer))
    `(with-current-buffer (find-file-noselect ,cache-file nil 'literal)
       ,@load-list
       (eval-buffer)
       (kill-buffer))))

(defmacro enable--with-eval (args state-file)
  (with-current-buffer (find-file-noselect state-file nil 'literal)
    (erase-buffer)
    (print args (current-buffer))
    (save-buffer)
    (kill-buffer))
  (macroexp-progn (macroexpand `(enable--process ,args))))

(defun enable--make-pkg-defaults (pkg-defaults)
  (dolist (pkg-assoc pkg-defaults)
    (let ((module (car pkg-assoc))
          (defaults (cdr pkg-assoc)))
      (eval `(defvar ,(intern (concat "enable--"
                                      (symbol-name module)
                                      "-pkg-defaults"))
               ',defaults)))))

;;; (current-buffer) visits cache-file
(defun enable-using-cache (file-path)
  (let* ((file-buffer (find-file-noselect file-path nil 'literal)))
    (ignore-errors (while t (print (read file-buffer) (current-buffer))))
    (kill-buffer file-buffer)))

(defun enable-using-eval (file-path)
  (load file-path nil 'nomessage))

(defun enable-reload-additively ()
  (interactive)
  (enable-purge-cache)
  (load early-init-file nil 'no-message)
  (load user-init-file nil 'no-message))

(defun enable-purge-cache ()
  (interactive)
  (dolist (file (list enable--cache-state-file
                      enable--cache-file
                      enable--early-cache-file
                      enable--early-cache-state-file))
    (delete-file file)))

(defmacro enable (&rest args)
  (if (eq enable-loader #'enable-using-cache)
      `(enable--with-cache ,enable--cache-file ,enable--cache-state-file ,args)
    `(enable--with-eval ,args ,enable--cache-state-file)))

(defmacro enable-early (&rest args)
  (if (eq enable-loader #'enable-using-cache)
      `(enable--with-cache ,enable--early-cache-file ,enable--early-cache-state-file ,args)
    `(enable--with-eval ,args ,enable--early-cache-state-file)))

;;;###autoload
(defun enable-init (&optional pkg-defaults)
  (enable--make-pkg-defaults pkg-defaults)
  (dolist (module enable--modules)
    (let ((submodules))
      (eval `(defvar ,(intern (concat "enable--"
                                      (substring (symbol-name module) 1)
                                      "-sub-all"))
               ',(mapcar (lambda (submodule)
                           (intern (file-name-sans-extension submodule)))
                         (enable--get-files (concat (substring (symbol-name module) 1)
                                                    "/submodules/"))))))))
