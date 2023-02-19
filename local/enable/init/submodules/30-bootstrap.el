;;; bootstrap.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)
(setq package-user-dir (concat @dir-local "elpa"))
(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") 'append))

;;; straight - Package Manager

;; TODO: move straight to @dir-local
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

;;; use-package - Configurationieer

(straight-use-package 'use-package)

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

