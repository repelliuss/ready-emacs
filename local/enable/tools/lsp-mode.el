;;; lsp-mode.el -*- lexical-binding: t; -*-

;; This should be loaded early I guess for lsp-mode
(setenv "LSP_USE_PLISTS" "true")

;; For compilation, make sure it is t before installing
(setq lsp-use-plists t
      lsp-keymap-prefix "M-l")

(cfg-pkg (:elpaca lsp-mode
                  :files (:defaults "clients/*.el" "clients/lsp-roslyn-stdpipe.ps1"))
  (:opt lsp-session-file (concat rps-dir-cache "lsp-mode/session")
        lsp-server-install-dir (concat rps-dir-cache "lsp-mode/servers")
        lsp-idle-delay 0.5
        lsp-inlay-hint-enable nil
        lsp-enable-on-type-formatting nil
        lsp-enable-file-watchers nil
        lsp-keep-workspace-alive nil
        lsp-headerline-breadcrumb-enable-diagnostics t
        lsp-headerline-breadcrumb-enable-symbol-numbers nil
        lsp-headerline-breadcrumb-enable nil
        lsp-headerline-breadcrumb-segments '(symbols)
        lsp-modeline-code-actions-enable nil
        lsp-auto-execute-action nil)

  (:hook #'lsp-enable-which-key-integration)
  (:autoload lsp-deferred)

  (:face lsp-inlay-hint-face (:height 60))

  (:after lsp-modeline
    (:face lsp-modeline-code-actions-preferred-face (:foreground "blue")))

  (:after lsp-clangd
    (:prepend* lsp-clients-clangd-args '("--header-insertion=never"
                                         "--header-insertion-decorators=0"
                                         "-j=12"
                                         "--clang-tidy"
                                         "--rename-file-limit=0"
                                         "--pch-storage=memory"
                                         "--background-index"
                                         "--log=verbose"
                                         "--completion-style=detailed"))))

(cfg-pkg lsp-treemacs
  (:autoload lsp-treemacs-errors-list)

  ;; Fix errors list
  (when rps-system-windows-p
    (:advice-to '(lsp-f-ancestor-of? lsp-f-same?) :filter-args
      #'rps-lsp-downcase-path-args)))

(defun rps-lsp-downcase-path-args (path-args)
  (mapcar #'downcase path-args))

(cfg-pkg consult-lsp
  (:after lsp-mode
    (:bind (lsp-mode-map
            (:prefix lsp-keymap-prefix
              "!" #'consult-lsp-diagnostics
              "i" #'consult-lsp-file-symbols
              "s" #'consult-lsp-symbols))
           (rps-keymap-normal
            "M-i" #'rps-consult-lsp-safe-imenu))))

(defun rps-consult-lsp-safe-imenu ()
  (interactive)
  (condition-case nil
      (consult-lsp-file-symbols 'group)
    (error (consult-imenu))))

(cfg-pkg lsp-ui
  (:opt lsp-ui-sideline-show-code-actions nil
        lsp-ui-sideline-enable nil
        lsp-ui-sideline-show-symbol t
        lsp-ui-sideline-show-hover nil
        lsp-ui-doc-show-with-mouse nil))
