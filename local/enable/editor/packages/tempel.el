;;; tempel.el -*- lexical-binding: t; -*-

(use-package tempel
  :init
  (defun tempel-setup-capf ()
    (interactive)
    (add-hook 'completion-at-point-functions #'tempel-expand -90 'local))

  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  (add-hook 'lsp-completion-mode-hook 'tempel-setup-capf)

  (setq tempel-file (concat @dir-local "tempel"))

  :config
  (bind tempel-map
	"M-q" #'tempel-abort
	"M-j" #'tempel-next
	"M-k" #'tempel-previous
	"M-d" #'tempel-kill
	"M-c" #'tempel-done)
  
  :extend (meow)
  (dolist (entry '(tempel-expand tempel-insert))
    (advice-add entry :after (lambda (&rest _)
			       (meow-insert)))))
