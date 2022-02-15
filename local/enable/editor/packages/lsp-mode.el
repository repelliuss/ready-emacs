;;; lsp-mode.el -*- lexical-binding: t; -*-

(use-package lsp-mode
  :init
  (setq lsp-session-file (concat cache-dir "lsp-mode/session")
        lsp-server-install-dir (concat local-dir "lsp-mode/servers"))

  (setq lsp-keymap-prefix "M-l")

  (setq lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil)

  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
