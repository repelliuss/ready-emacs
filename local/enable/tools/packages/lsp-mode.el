;;; lsp-mode.el -*- lexical-binding: t; -*-

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-session-file (concat cache-dir "lsp-mode/session")
        lsp-server-install-dir (concat local-dir "lsp-mode/servers"))

  (setq lsp-keymap-prefix "M-l")

  (setq lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil)

  (add-hook 'c-mode-common-hook #'lsp-deferred)

  (add-hook 'lsp-mode-hook (lambda ()
			     (setq-local read-process-output-max (* 1024 1024))))

  :config
  (advice-add #'lsp-hover
	      :around
	      (defun lsp-hover-respect-error (fn)
		(if (not (flymake-diagnostics (point)))
		    (funcall fn))))

  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(use-package lsp-mode
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (defun lsp-mode-setup-orderless-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless))) ;; Configure orderless

  (add-hook 'lsp-completion-mode-hook (lambda ()
					(setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point)))))
  
  :hook
  (lsp-completion-mode . lsp-mode-setup-orderless-completion))

;; TODO: corfu weird insertion
;; TODO: when there is an error, signature overrides it
;; TODO: check java completion show details
