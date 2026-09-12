;;; typescript.el -*- lexical-binding: t; -*-

(cfg typescript-ts-mode
  (:after lsp-mode
    (:hook-to 'typescript-ts-base-mode #'lsp-deferred #'lsp-inlay-hints-mode))
  (:opt typescript-ts-mode-indent-offset 4))


