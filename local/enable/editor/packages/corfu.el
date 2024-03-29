;;; corfu.el -*- lexical-binding: t; -*-

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)         ;; Enable cycling for `corfu-next/previous'
  (corfu-scroll-margin 5) ;; Use scroll margin

  :attach (eshell)
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-quit-at-boundary t
                          corfu-quit-no-match t
                          corfu-auto nil)
              (corfu-mode)))

  :attach (cape)
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)
  
  :init
  (global-corfu-mode 1)

  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer if `completion-at-point' is bound."
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      ;; (setq-local corfu-auto nil) Enable/disable auto completion
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)
  
  :config
  (bind corfu-map
	"SPC" #'corfu-insert-separator
	"M-j" #'corfu-next
	"M-k" #'corfu-previous
	"C-<" #'corfu-first
	"C->" #'corfu-last
	"M-<" #'corfu-scroll-down
	"M->" #'corfu-scroll-up))

;; NOTE: doesn't work with lsp-mode
(use-package corfu-history
  :straight (:local-repo "corfu/extensions")
  :attach (savehist)
  (add-to-list 'savehist-additional-variables 'corfu-history)
  :attach (corfu)
  (corfu-history-mode 1))

(use-package corfu-quick
  :straight (:local-repo "corfu/extensions")
  :attach (corfu)
  (bind corfu-map
	"M-a" #'corfu-quick-insert
	"M-A" #'corfu-quick-complete))

(use-package corfu-info
  :straight (:local-repo "corfu/extensions"))

(use-package dabbrev
  :init
  ;; Swap M-/ and C-M-/
  (bind (current-global-map)
	"M-/" #'dabbrev-completion
	"C-M-/" #'dabbrev-expand))


