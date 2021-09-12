;;; config.el -*- lexical-binding: t; -*-

(defvar rdy/emacs-directory (concat user-emacs-directory "ready/"))
(defvar rdy/modules-directory (concat rdy/emacs-directory "modules/"))
(defvar rdy/cache-directory (concat rdy/emacs-directory "cache/"))

(defun rdy--get-files (&optional path)
  (directory-files (concat rdy/modules-directory path)
                   nil directory-files-no-dot-files-regexp t))

(defvar rdy--modules (mapcar (lambda (module-name)
                               (intern (concat ":" (file-name-sans-extension module-name))))
                             (rdy--get-files)))

(defun rdy--enable-files  (module files &optional packages-p)
  (let* ((module-name (substring (symbol-name module) 1))
         (module-path (concat rdy/modules-directory module-name "/")))
    (require (intern (concat "rdy/" module-name)) (concat module-path "config"))
    (let ((path (concat module-path (if packages-p
                                        "packages/"
                                      "submodules/"))))
      (dolist (file files)
        (load (concat path (if (symbolp file)
                               (symbol-name file)
                             file)) nil 'nomessage)))))

(defun rdy--enable-module-all (module)
  (rdy--enable-files module
                     (eval (intern (concat "rdy--"
                                           (substring (symbol-name module) 1)
                                           "-sub-all"))))
  (rdy--enable-files module
                     (eval
                      (intern (concat "rdy--"
                                      (substring (symbol-name module) 1)
                                      "-pkg-defaults")))
                     'packages))

(defun rdy--enable-all ()
  (dolist (module rdy--modules)
    (rdy--enable-module-all module)))

(defun rdy--modify-list (var modifications)
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

(defmacro enable! (&rest args)
  (cond ((eq 'all (car args))
         '(rdy--enable-all))
        ((not (memq (car args) rdy--modules))
         (error "No module name given to `rdy-enable'"))
        (t (let ((module)
                 (load-list)
                 (expr (car args))
                 (args (cdr args)))
             (while expr
               (cond
                ((memq expr rdy--modules)
                 (setq module expr)
                 (when (eq 'all (car args))
                   (push `(rdy--enable-module-all ,module) load-list)
                   (setq args (cdr args))))
                ((eq expr :sub)
                 (if (not (listp (car args)))
                     (error "`:sub' arg is not a list for `%s' in `rdy-enable'" module)
                   (if (not (eq 'all (caar args)))
                       (push `(rdy--enable-files ,module ',(car args)) load-list)
                     (let ((sub-all (eval (intern (concat "rdy--"
                                                          (substring (symbol-name module) 1)
                                                          "-sub-all")))))
                       (push `(rdy--enable-files ,module
                                                 ',(rdy--modify-list sub-all (cdar args)))
                             load-list))
                     (setq args (cdr args)))))
                ((eq expr :pkg)
                 (if (not (listp (car args)))
                     (error "`:pkg' arg is not a list for `%s' in `rdy-enable'" module)
                   (if (not (eq 'defaults (caar args)))
                       (push `(rdy--enable-files ,module ',(car args) t) load-list)
                     (let ((pkg-defaults (eval (intern (concat "rdy--"
                                                               (substring (symbol-name module) 1)
                                                               "-pkg-defaults")))))
                       (push `(rdy--enable-files ,module
                                                 ',(rdy--modify-list pkg-defaults (cdar args)) 'packages)
                             load-list))
                     (setq args (cdr args))))))
               (setq expr (car args)
                     args (cdr args)))
             (macroexp-progn load-list)))))

(dolist (module rdy--modules)
  (let ((submodules))
    (eval `(defvar ,(intern (concat "rdy--"
                                    (substring (symbol-name module) 1)
                                    "-sub-all"))
             ',(mapcar (lambda (submodule)
                         (intern (file-name-sans-extension submodule)))
                       (rdy--get-files (concat (substring (symbol-name module) 1)
                                               "/submodules/")))))))

(let ((pkg-defaults '((base   . (gcmh))

                      (editor . (meow
                                 which-key
                                 orderless
                                 selectrum
                                 marginalia
                                 ace-window
                                 golden-ratio))

                      (ui     . (mood-line))

                      (ux     . nil)

                      (tools  . nil)

                      (lang   . (org)))))

  (dolist (pkg-assoc pkg-defaults)
    (let ((module (car pkg-assoc))
          (defaults (cdr pkg-assoc)))
      (eval `(defvar ,(intern (concat "rdy--"
                                      (symbol-name module)
                                      "-pkg-defaults"))
               ',defaults)))))

(provide 'rdy/base)
(enable! :base all)
(setq rdy--modules (delq :base rdy--modules))
