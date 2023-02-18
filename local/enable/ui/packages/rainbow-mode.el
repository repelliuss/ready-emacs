;;; rainbow-mode.el -*- lexical-binding: t; -*-

(use-package rainbow-mode
  :init
  (add-hook 'prog-mode-hook #'rainbow-mode))
