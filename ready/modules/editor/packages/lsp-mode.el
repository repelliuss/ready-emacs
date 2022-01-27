;;; lsp-mode.el -*- lexical-binding: t; -*-

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "M-l"
        lsp-session-file (concat ready/cache-directory "lsp-session")
        lsp-server-install-dir (concat ready/opt-directory "lsp"))

  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
