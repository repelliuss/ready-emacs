;;; config.el -*- lexical-binding: t; -*-

(defvar rdy--emacs-directory (concat user-emacs-directory "ready/"))

(defun rdy--get-files (&optional path)
  (directory-files (concat rdy--emacs-directory path)
                   nil directory-files-no-dot-files-regexp t))

(defvar rdy--modules (mapcar (lambda (module-name)
                               (intern (concat ":"
                                               (file-name-sans-extension module-name))))
                             (rdy--get-files)))

(defun rdy--enable-files  (module files &optional packages-p)
  (let* ((module-name (substring (symbol-name module) 1))
         (module-path (concat rdy--emacs-directory module-name "/")))
    (require (intern (concat "rdy/" module-name)) (concat module-path "config"))
    (let ((path (concat module-path (if packages-p
                                        "packages/"
                                      "submodules/"))))
      (dolist (file files)
        (load (concat path (if (symbolp file)
                               (symbol-name file)
                             file)) t t)))))

(defun rdy--enable-submodule-all (module)
  (rdy--enable-files module (directory-files (concat rdy--emacs-directory
                                                    (substring (symbol-name module) 1)
                                                    "/submodules/")
                                            nil directory-files-no-dot-files-regexp t)))

(defun rdy--enable-module-all (module)
  (rdy--enable-submodule-all module)
  (rdy--enable-files module '(defaults) t))

(defun rdy--enable-all ()
  (dolist (module rdy--modules)
    (rdy--enable-module-all module)))

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
                       (push `(rdy--enable-files ,module ,(car args)) load-list)
                     (push `(rdy--enable-submodule-all ,module) load-list)
                     (setq args (cdr args)))))
                ((eq expr :pkg)
                 (if (not (listp (car args)))
                     (error "`:pkg' arg is not a list for `%s' in `rdy-enable'" module)
                   (push `(rdy--enable-files ,module ',(car args) t) load-list))))
               (setq expr (car args)
                     args (cdr args)))
             (macroexp-progn load-list)))))

(let ((_))
  (dolist (module rdy--modules)
    (let ((submodules))
      (eval `(defvar ,(intern (concat "rdy/"
                                      (substring (symbol-name module) 1)
                                      "-sub-all"))
               ',(mapcar (lambda (submodule)
                           (intern (file-name-sans-extension submodule)))
                         (rdy--get-files (concat (substring (symbol-name module) 1)
                                                 "/submodules/"))))))))

(let ((pkg-defaults '((base   . (gcmh))

                      (editor . (meow
                                 which-key
                                 orderless
                                 selectrum
                                 marginalia
                                 ace-window
                                 golden-ratio))

                      (ui     . (mood-line)))))

  (dolist (pkg-assoc pkg-defaults)
    (let ((module (car pkg-assoc))
          (defaults (cdr pkg-assoc)))
      (eval `(defvar ,(intern (concat "rdy/"
                                      (symbol-name module)
                                      "-pkg-defaults"))
               ',defaults)))))

(provide 'rdy/base)
(enable! :base all)
(setq rdy--modules (delq :base rdy--modules))
