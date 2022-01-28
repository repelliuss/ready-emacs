;;; config.el -*- lexical-binding: t; -*-

;;; Customizations

;; TODO: default to emacs
(defcustom ready-package-backend 'straight
  "Package management handler for Ready Emacs.")

(defcustom ready-force-build-cache nil
  "Always re-build cache at initialization.")

(defcustom ready-theme-preferred-background 'light
  "Preferred background lightning for theme packages.")

;;; Module system handler

(defvar ready/emacs-directory (concat user-emacs-directory "ready/"))
(defvar ready/modules-directory (concat ready/emacs-directory "modules/"))
(defvar ready/cache-directory (concat ready/emacs-directory "cache/"))
(defvar ready/opt-directory (concat ready/emacs-directory "opt/"))

(defvar ready--cache-file (concat ready/cache-directory "ready-cache.el"))
(defvar ready--early-cache-file (concat ready/cache-directory "ready-early-cache.el"))
(defvar ready--cache-state-file (concat ready/cache-directory "ready-cache-state.el"))
(defvar ready--early-cache-state-file (concat ready/cache-directory "ready-early-cache-state.el"))

(defun ready--get-files (&optional path)
  (directory-files (concat ready/modules-directory path)
                   nil directory-files-no-dot-files-regexp t))

(defvar ready--modules (mapcar (lambda (module-name)
                                 (intern (concat ":" (file-name-sans-extension module-name))))
                               (ready--get-files)))

(defun ready--build-cache (module files cache-file &optional packages-p)
  (let* ((module-path (concat ready/modules-directory (substring (symbol-name module) 1) "/"))
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

(defun ready--build-cache-module (module cache-file)
  (ready--build-cache module
                       (eval
                        (intern (concat "ready--"
                                        (substring (symbol-name module) 1)
                                        "-pkg-defaults")))
                       cache-file
                       'packages)
  (ready--build-cache module
                       (eval (intern (concat "ready--"
                                             (substring (symbol-name module) 1)
                                             "-sub-all")))
                       cache-file))

(defun ready--build-cache-all (cache-file)
  (dolist (module ready--modules)
    (ready--build-cache-module module cache-file)))

;; TODO: add support for package-name* -suffix +suffix feat
(defun ready--modify-list (var modifications)
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
  `(enable--with-cache ,ready--cache-file ,ready--cache-state-file ,args))

(defmacro enable-early! (&rest args)
  `(enable--with-cache ,ready--early-cache-file ,ready--early-cache-state-file ,args))

(defmacro enable--with-cache (cache-file state-file args)
  (let ((state-buffer (find-file-noselect state-file nil 'literal))
        load-list)
    (if (and (file-exists-p cache-file)
             (equal args (ignore-errors (read state-buffer)))
             (not ready-force-build-cache))
        (setq load-list `((load ,cache-file nil 'nomessage)))
      (with-current-buffer state-buffer
        (erase-buffer)
        (print args (current-buffer))
        (save-buffer))
      (delete-file cache-file)
      (cond ((eq 'all (car args))
             '(ready--build-cache-all ,cache-file))
            ((not (memq (car args) ready--modules))
             (error "No module name given to `ready-enable'"))
            (t (let (module
                     (expr (car args))
                     (args (cdr args)))
                 (while expr
                   (cond
                    ((memq expr ready--modules)
                     (setq module expr)
                     (when (eq 'all (car args))
                       (push `(ready--build-cache-module ,module ,cache-file) load-list)
                       (setq args (cdr args))))
                    ((eq expr :sub)
                     (if (not (listp (car args)))
                         (error "`:sub' arg is not a list for `%s' in `ready-enable'" module)
                       (if (not (eq 'all (caar args)))
                           (setq load-list (nconc load-list `((ready--build-cache ,module ',(car args) ,cache-file))))
                         (let ((sub-all (eval (intern (concat "ready--"
                                                              (substring (symbol-name module) 1)
                                                              "-sub-all")))))
                           (setq load-list (nconc load-list
                                                  `((ready--build-cache ,module
                                                                        ',(ready--modify-list sub-all (cdar args))
                                                                        ,cache-file)))))
                         (setq args (cdr args)))))
                    ((eq expr :pkg)
                     (if (not (listp (car args)))
                         (error "`:pkg' arg is not a list for `%s' in `ready-enable'" module)
                       (if (not (eq 'defaults (caar args)))
                           (push `(ready--build-cache ,module ',(car args) ,cache-file 'packages) load-list)
                         (let ((pkg-defaults (eval (intern (concat "ready--"
                                                                   (substring (symbol-name module) 1)
                                                                   "-pkg-defaults")))))
                           (push `(ready--build-cache ,module
                                                      ',(ready--modify-list pkg-defaults (cdar args))
                                                      ,cache-file
                                                      'packages)
                                 load-list))
                         (setq args (cdr args))))))
                   (setq expr (car args)
                         args (cdr args)))
                 (setq load-list (nconc load-list `((with-current-buffer (find-file-noselect ,cache-file nil 'literal)
                                                      (save-buffer)
                                                      (eval-buffer)
                                                      (kill-buffer)))))))))
    (kill-buffer state-buffer)
    (macroexp-progn load-list)))

(dolist (module ready--modules)
  (let ((submodules))
    (eval `(defvar ,(intern (concat "ready--"
                                    (substring (symbol-name module) 1)
                                    "-sub-all"))
             ',(mapcar (lambda (submodule)
                         (intern (file-name-sans-extension submodule)))
                       (ready--get-files (concat (substring (symbol-name module) 1)
                                                 "/submodules/")))))))

(let ((pkg-defaults '((editor . (meow
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
      (eval `(defvar ,(intern (concat "ready--"
                                      (symbol-name module)
                                      "-pkg-defaults"))
               ',defaults)))))

;;; Package Management Handler

(when (eq ready-package-backend 'straight)
  (setq straight-use-package-by-default t
        straight-check-for-modifications '(check-on-save find-when-checking))
  (let ((bootstrap-file
         (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
        (bootstrap-version 5))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
           "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
           'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage))

  ;; TODO: remove this, use-package is a dependency
  (straight-use-package 'use-package))

(with-eval-after-load 'use-package-core
  (setq use-package-always-defer t)
  (setq use-package-keywords
        (use-package-list-insert :extend
                                 (use-package-list-insert :attach
                                                          use-package-keywords
                                                          :init)
                                 :config 'after))

  (defun use-package-normalize/:attach (_ _ args)
    (list args))

  (defun use-package-handler/:attach (name keyword forms rest state)
    (let  ((body (use-package-process-keywords name rest state))
           sexps)
      (dolist (extend forms `(,@sexps ,@body))
        (setq sexps
              (nconc sexps
                     (use-package-require-after-load (car extend) (cdr extend)))))))

  (defalias 'use-package-normalize/:extend #'use-package-normalize/:attach)
  (defalias 'use-package-handler/:extend #'use-package-handler/:attach))

;; TODO: remove this, general is a dependency
(use-package general :demand t)
