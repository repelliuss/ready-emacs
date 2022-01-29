;;; config.el -*- lexical-binding: t; -*-

(defgroup enable nil
  "A configuration manager."
  :group 'convenience
  :prefix "enable-")

;;; Customizations

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

(defcustom enable-force-build-cache nil
  "Always re-build cache at initialization.")

;;; Module system handler


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

(defun enable--build-cache (module files cache-file &optional packages-p)
  (let* ((module-path (concat enable-modules-dir (substring (symbol-name module) 1) "/"))
         (path (concat module-path (if packages-p "packages/" "submodules/"))))
    (with-current-buffer (find-file-noselect cache-file nil 'literal)
      (dolist (file files)
        (let* ((file-buffer (find-file-noselect (concat path
                                                        (if (symbolp file)
                                                            (symbol-name file)
                                                          file)
                                                        ".el")
                                                nil 'literal)))
          (ignore-errors (while t (print (read file-buffer) (current-buffer))))
          (kill-buffer file-buffer))))))

(defun enable--build-cache-module (module cache-file)
  (let ((pkg-defaults (intern (concat "enable--"
                                      (substring (symbol-name module) 1)
                                      "-pkg-defaults"))))
    (when (boundp pkg-defaults)
      (enable--build-cache module
                           (eval pkg-defaults)
                           cache-file
                           'packages)))
  (enable--build-cache module
                       (eval (intern (concat "enable--"
                                             (substring (symbol-name module) 1)
                                             "-sub-all")))
                       cache-file))

(defun enable--build-cache-all (cache-file)
  (dolist (module enable--modules)
    (enable--build-cache-module module cache-file)))

;; TODO: add support for package-name* -suffix +suffix feat
(defun enable--modify-list (var modifications)
  (mapc (lambda (subarg)
          (cond
           ((char-equal ?- (elt (symbol-name subarg) 0))
            (setq var (delq (intern (substring (symbol-name subarg) 1))
                            var)))
           ((char-equal ?+ (elt (symbol-name subarg) 0))
            (push (make-symbol (substring (symbol-name subarg) 1))
                  var))))
        modifications)
  var)

(defmacro enable (&rest args)
  `(enable--with-cache ,enable--cache-file ,enable--cache-state-file ,args))

(defmacro enable-early (&rest args)
  `(enable--with-cache ,enable--early-cache-file ,enable--early-cache-state-file ,args))

(defun enable--save-cache-state (args buffer)
  (with-current-buffer buffer
        (erase-buffer)
        (print args buffer)
        (save-buffer)))

(defmacro enable--with-cache (cache-file state-file args)
  (let* (load-list
         (queue-to-load (lambda (expr)
                          (setq load-list (nconc load-list (list expr)))))
         (state-buffer (find-file-noselect state-file nil 'literal)))
    (if (and (file-exists-p cache-file)
             (equal args (ignore-errors (read state-buffer)))
             (not enable-force-build-cache))
        (setq load-list `((load ,cache-file nil 'nomessage)))
      (enable--save-cache-state args state-buffer)
      (delete-file cache-file)
      (cond ((eq 'all (car args))
             '(enable--build-cache-all ,cache-file))
            ((not (memq (car args) enable--modules))
             (error "No module name given to `enable-enable'"))
            (t (let (module
                     (expr (car args))
                     (args (cdr args)))
                 (while expr
                   (cond
                    ((memq expr enable--modules)
                     (setq module expr)
                     (when (eq 'all (car args))
                       (funcall queue-to-load `(enable--build-cache-module ,module ,cache-file))
                       (setq args (cdr args))))
                    ((eq expr :sub)
                     (if (not (listp (car args)))
                         (error "`:sub' arg is not a list for `%s' in `enable'" module)
                       (if (not (eq 'all (caar args)))
                           (funcall queue-to-load `(enable--build-cache ,module ',(car args) ,cache-file))
                         (let ((sub-all (eval (intern (concat "enable--"
                                                              (substring (symbol-name module) 1)
                                                              "-sub-all")))))
                           (funcall queue-to-load `(enable--build-cache ,module
                                                                        ',(enable--modify-list sub-all (cdar args))
                                                                        ,cache-file)))
                         (setq args (cdr args)))))
                    ((eq expr :pkg)
                     (if (not (listp (car args)))
                         (error "`:pkg' arg is not a list for `%s' in `enable'" module)
                       (if (not (eq 'defaults (caar args)))
                           (funcall queue-to-load `(enable--build-cache ,module ',(car args) ,cache-file 'packages))
                         (let ((pkg-defaults (eval (intern (concat "enable--"
                                                                   (substring (symbol-name module) 1)
                                                                   "-pkg-defaults")))))
                           (funcall queue-to-load `(enable--build-cache ,module
                                                                        ',(enable--modify-list pkg-defaults (cdar args))
                                                                        ,cache-file
                                                                        'packages)))
                         (setq args (cdr args))))))
                   (setq expr (car args)
                         args (cdr args)))
                 (funcall queue-to-load `(with-current-buffer (find-file-noselect ,cache-file nil 'literal)
                                           (save-buffer)
                                           (eval-buffer)
                                           (kill-buffer)))))))
    (kill-buffer state-buffer)
    (macroexp-progn load-list)))

(dolist (module enable--modules)
  (let ((submodules))
    (eval `(defvar ,(intern (concat "enable--"
                                    (substring (symbol-name module) 1)
                                    "-sub-all"))
             ',(mapcar (lambda (submodule)
                         (intern (file-name-sans-extension submodule)))
                       (enable--get-files (concat (substring (symbol-name module) 1)
                                                 "/submodules/")))))))

(let ((pkg-defaults '(

                      (editor . (meow
                                 ace-window
                                 embark
                                 consult
                                 vertico))

                      (tools  . ())

                      (lang   . (org))

                      (ui     . ())

                      (ux     . (which-key
                                 orderless
                                 marginalia
                                 gcmh)))))
  (dolist (pkg-assoc pkg-defaults)
    (let ((module (car pkg-assoc))
          (defaults (cdr pkg-assoc)))
      (eval `(defvar ,(intern (concat "enable--"
                                      (symbol-name module)
                                      "-pkg-defaults"))
               ',defaults)))))
