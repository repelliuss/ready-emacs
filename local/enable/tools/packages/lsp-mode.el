;;; lsp-mode.el -*- lexical-binding: t; -*-

(add-to-list 'exec-path (expand-file-name "~/.local/bin"))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :attach (typescript-mode)
  (add-hook 'typescript-mode-hook #'lsp-deferred)
  
  :attach (php-mode)
  (add-hook 'php-mode-hook #'lsp-deferred)

  :attach (verilog-mode)
  (add-hook 'verilog-mode-hook #'lsp-deferred)

  :attach (cc-mode)
  (add-hook 'c-mode-hook #'lsp-deferred)
  (add-hook 'c++-mode-hook #'lsp-deferred)
  
  :attach (rust-mode)
  (add-hook 'rust-mode-hook #'lsp-deferred)
  
  :init
  (setq lsp-session-file (concat cache-dir "lsp-mode/session")
        lsp-server-install-dir (concat cache-dir "lsp-mode/servers"))

  (setq lsp-keymap-prefix "M-l")

  (setq lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil)

  (add-hook 'lsp-mode-hook (lambda ()
			     (setq-local read-process-output-max (* 1024 1024))))

  ;; :config
  ;; (advice-add #'lsp-hover
  ;; 	      :around
  ;; 	      (defun lsp-hover-respect-error (fn)
  ;; 		(if (not (funcall eldoc-documentation-strategy))
  ;; 		    (funcall fn))))

  :extend (which-key)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)

  :extend (php-mode)
  (setq lsp-intelephense-storage-path
	(concat cache-dir
		"lsp-mode/servers/intelephense")))

(use-package lsp-mode
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (defun lsp-mode-setup-orderless-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless))) ;; Configure orderless

  (add-hook 'lsp-completion-mode-hook
	    (lambda ()
	      (add-hook 'completion-at-point-functions
			(cape-capf-buster #'lsp-completion-at-point)
			nil 'local)
	      (remove-hook 'completion-at-point-functions
			   #'lsp-completion-at-point 'local)))
  
  :config
  (add-hook 'lsp-completion-mode-hook 'lsp-mode-setup-orderless-completion 90))

;; TODO: corfu weird insertion
;; TODO: when there is an error, signature overrides it
;; TODO: check java completion show details






