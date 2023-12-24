;;; lsp-mode.el -*- lexical-binding: t; -*-

;; for compilation, make sure it is t before installing
(setq lsp-use-plists t)

(setup lsp-mode
  (:autoload lsp-deferred)
  (:with-function lsp-deferred
    (:hook-into c-ts-base-mode shader-mode csharp-mode csharp-ts-mode))

  ;; (advice-add #'lsp-hover
  ;; 	      :around
  ;; 	      (defun lsp-hover-respect-error (fn)
  ;; 		(if (not (funcall eldoc-documentation-strategy))
  ;; 		    (fun
  
  (:set lsp-session-file (concat ~dir-cache "lsp-mode/session")
        lsp-server-install-dir (concat ~dir-cache "lsp-mode/servers")
        lsp-keymap-prefix "M-l"
        lsp-idle-delay 0.5
        ;; lsp-lens-enable nil
		;; lsp-headerline-breadcrumb-enable nil
		;; lsp-enable-on-type-formatting nil
		;; lsp-enable-indentation nil
		;; lsp-javascript-format-enable nil
		;; lsp-typescript-format-enable nil
		;; lsp-treemacs-error-list-severity 4

        (prepend* lsp-clients-clangd-args) '("--header-insertion=never"
                                             "--header-insertion-decorators=0"
                                             "-j=4"
                                             "--clang-tidy"
                                             "--pch-storage=memory"
                                             "--background-index"
                                             "--completion-style=detailed")
        )
  

  (:hook lsp-enable-which-key-integration))

(setup lsp-treemacs
  (:autoload lsp-treemacs-errors-list)

  ;; Fix errors list
  (defun lsp-f-ancestor-of-patch (path-args)
    (mapcar (lambda (path) (downcase path)) path-args))

  (when ~os-windows-p
    (advice-add 'lsp-f-ancestor-of? :filter-args #'lsp-f-ancestor-of-patch)
    (advice-add 'lsp-f-same? :filter-args #'lsp-f-ancestor-of-patch)))

;; TODO: corfu weird insertion
;; TODO: when there is an error, signature overrides it
;; TODO: check java completion show details



