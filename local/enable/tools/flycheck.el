;;; flycheck.el -*- lexical-binding: t; -*-

(cfg-pkg flycheck
  (:hook-into lsp-mode eglot-managed-mode)
  (:opt flycheck-indication-mode nil)
  (put 'flycheck-disabled-checkers 'safe-local-variable #'listp))

(cfg-pkg consult-flycheck
  (:bind rps-keymap-normal "!" #'consult-flycheck))

(cfg-pkg flycheck-eglot
  (:hook-into eglot-managed-mode))
