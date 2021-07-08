;;; config.el -*- lexical-binding: t; -*-

(defvar rps/emacs-directory (concat user-emacs-directory "rps/"))
(defvar rps/modules '(:base :editor :ui)) ; base module gets removed after loading

(defun rps/enable-files  (module files &optional packages-p)
  (let* ((module-name (substring (symbol-name module) 1))
         (module-path (concat rps/emacs-directory module-name "/")))
    (require (intern (concat "rps-" module-name)) (concat module-path "config"))
    (let ((path (concat module-path (if packages-p
                                        "packages/"
                                      "submodules/"))))
      (dolist (file files)
        (load (concat path (if (symbolp file)
                               (symbol-name file)
                             file)) t t)))))

(defun rps/enable-submodule-all (module)
  (rps/enable-files module (directory-files (concat rps/emacs-directory
                                                    (substring (symbol-name module) 1)
                                                    "/submodules/")
                                            nil directory-files-no-dot-files-regexp t)))

(defun rps/enable-module-all (module)
  (rps/enable-submodule-all module)
  (rps/enable-files module '(defaults) t))

(defun rps/enable-all ()
  (dolist (module rps/modules)
    (rps/enable-module-all module)))

(defmacro enable! (&rest args)
  (cond ((eq 'all (car args))
         '(rps/enable-all))
        ((not (memq (car args) rps/modules))
         (error "No module name given to `rps/enable'"))
        (t (let ((module)
                 (load-list)
                 (expr (car args))
                 (args (cdr args)))
             (while expr
               (cond
                ((memq expr rps/modules)
                 (setq module expr)
                 (when (eq 'all (car args))
                   (push `(rps/enable-module-all ,module) load-list)
                   (setq args (cdr args))))
                ((eq expr :sub)
                 (if (not (listp (car args)))
                     (error "`:sub' arg is not a list for `%s' in `rps/enable'" module)
                   (if (not (eq 'all (caar args)))
                       (push `(rps/enable-files ,module ,(car args)) load-list)
                     (push `(rps/enable-submodule-all ,module) load-list)
                     (setq args (cdr args)))))
                ((eq expr :pkg)
                 (if (not (listp (car args)))
                     (error "`:pkg' arg is not a list for `%s' in `rps/enable'" module)
                   (push `(rps/enable-files ,module ',(car args) t) load-list))))
               (setq expr (car args)
                     args (cdr args)))
             (macroexp-progn load-list)))))

(provide 'rps-base)

(enable! :base all)
(setq rps/modules (delq :base rps/modules))
