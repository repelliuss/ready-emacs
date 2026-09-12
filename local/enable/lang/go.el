;;; go.el -*- lexical-binding: t; -*-

(store-install "go"
  :skip '(:system android))

(cfg go-ts-mode
  (:prepend exec-path (or (getenv "GOBIN") (:join-d rps-dir-home "go" "bin")))
  (:opt go-ts-mode-indent-offset 4)
  (:after lsp-mode
    (:hook #'lsp-deferred #'lsp-inlay-hints-mode)))
