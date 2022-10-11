;;; topspace.el -*- lexical-binding: t; -*-

(use-package topspace
  :attach (dired)
  (add-hook 'dired-mode-hook #'topspace-mode)

  :init
  (setq-default topspace-active t))
