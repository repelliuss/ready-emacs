;;; package.el -*- lexical-binding: t; -*-

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

(straight-use-package 'use-package)

(with-eval-after-load 'use-package-core
  (setq use-package-always-defer t)

  (setq use-package-keywords
        (use-package-list-insert :extend use-package-keywords :config 'after))

  (defun use-package-normalize/:extend (_ _ args)
    (list args))

  (defun use-package-handler/:extend (name-symbol keyword forms rest state)
    (let  ((body (use-package-process-keywords name-symbol rest state))
           extensions)
      (dolist (extend forms extensions)
        (setq extensions
              (nconc extensions
                     (use-package-require-after-load (car extend) (cdr extend))))))))

(use-package general :demand t)
