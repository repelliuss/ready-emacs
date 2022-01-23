;;; lsp-mode.el -*- lexical-binding: t; -*-

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "M-l")

  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
