;;; csharp.el -*- lexical-binding: t; -*-

(setup sharper
  (:autoload sharper-main-transient)
  (:after-feature csharp-mode
      (bind (csharp-mode-map csharp-ts-mode-map)
            (~bind-local
                "SPC" #'sharper-main-transient)))
  (when ~os-windows-p
    (:set (prepend exec-path) (concat ~dir-local "lsp/omnisharp-win-x64")))
  (when ~os-linux-p
    (:set (prepend exec-path) (concat ~dir-local "lsp/omnisharp-linux-x64-net6.0"))))
