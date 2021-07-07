;;; init.el -*- lexical-binding: t; -*-

(defmacro rps/load-modules (&rest modules)
  `(dolist (module ',modules)
    (load (concat user-emacs-directory "rps/" (symbol-name module) "/config"))))

(rps/load-modules base)

(load (concat user-emacs-directory "config"))

(use-package gcmh
  :demand
  :config
  (setq gcmh-idle-delay 5)
  (gcmh-mode 1))
