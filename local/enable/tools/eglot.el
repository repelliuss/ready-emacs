;;; eglot.el -*- lexical-binding: t; -*-

(cfg-pkg eglot
  (:opt eglot-extend-to-xref t)
  (:after-this
    (:prepend* eglot-server-programs '(((c-mode c++-mode) . ("clangd"
                                                                    "--header-insertion=never"
                                                                    "--header-insertion-decorators=0"
                                                                    "-j=4"
                                                                    "--clang-tidy"
                                                                    "--pch-storage=memory"
                                                                    "--background-index"
                                                                    "--completion-style=detailed"))
                                              ((shader-mode) "shader-ls.exe" "--stdio"))))

  (:hook-to '(c-ts-base-mode shader-mode csharp-mode csharp-ts-mode) #'eglot-ensure)

  (:after-this
    (:bind eglot-mode-map
           (:prefix "M-l"
             "a" #'eglot-code-actions
             "A" #'eglot-code-action-quickfix
             "f" #'eglot-format
             "F" #'eglot-format-buffer
             "r" #'eglot-rename
             "R" #'eglot-signal-didChangeConfiguration
             "g" #'eglot-find-declaration
             "i" #'eglot-find-implementation
             "t" #'eglot-find-typeDefinition
             "o" #'eglot-code-action-organize-imports
             "h" #'eldoc-doc-buffer
             (:prefix "w"
               "s" #'eglot-shutdown
               "S" #'eglot-shutdown-all
               "r" #'eglot-reconnect
               "l" #'eglot-list-connections
               "f" #'eglot-forget-pending-continuations
               "c" #'eglot-show-workspace-configuration)))

    (:face eglot-inlay-hint-face (:height 0.5))

    (:after (enable-event :file "local" "flymake")
      (:bind
        (:prefix "M-l"
          "e" #'rps-flymake-show-flymake-eldoc-function)))))

(cfg-pkg consult-eglot
  (:after eglot
    (:bind eglot-mode-map
           (:prefix "M-l"
             "s" #'consult-eglot-symbols))))




