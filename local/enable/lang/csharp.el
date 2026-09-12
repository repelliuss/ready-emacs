;;; csharp.el -*- lexical-binding: t; -*-

(cfg csharp-ts-mode
  (:after lsp-mode
    (:hook-to 'csharp-ts-mode #'lsp-deferred #'lsp-inlay-hints-mode)))

(cfg-pkg sharper
  (:after csharp-mode
    (:bind (list csharp-mode-map csharp-ts-mode-map)
           (:locally
            (:autoload
                "SPC" #'sharper-main-transient)))))
