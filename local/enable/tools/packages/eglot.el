;;; eglot.el -*- lexical-binding: t; -*-

(setup eglot
  (:set eglot-extend-to-xref t)
  
  (:when-loaded
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
    
    (:set (prepend* eglot-server-programs) '(((c-mode c++-mode) . ("clangd"
                                                                   "--header-insertion=never"
                                                                   "--header-insertion-decorators=0"
                                                                   "-j=4"
                                                                   "--clang-tidy"
                                                                   "--pch-storage=memory"
                                                                   "--background-index"
                                                                   "--completion-style=detailed"
                                                                   "-log=verbose"))
                                             ((shader-mode) "shader-ls.exe" "--stdio")))

    (:face eglot-inlay-hint-face (:height 0.5))

    (:after-feature enable-pkg-flymake
      ;; BUG: doesn't work without eglot-mode-map, fix bind-setup integration
      (:bind eglot-mode-map
             (:prefix "M-l"
               "e" #'~flymake-show-flymake-eldoc-function))))
  
  (:with-function eglot-ensure
    (:hook-into c-mode c++-mode shader-mode)))

(setup consult-eglot
  (:after-feature eglot
    (:bind eglot-mode-map
           (:prefix "M-l"
             "s" #'consult-eglot-symbols))))
