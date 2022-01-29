;;; lsp-mode.el -*- lexical-binding: t; -*-

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "M-l"
        lsp-session-file (concat cache-dir "lsp-mode/session")
        lsp-server-install-dir (concat local-dir "lsp-mode/servers"))
  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
