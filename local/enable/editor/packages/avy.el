;;; avy.el -*- lexical-binding: t; -*-

(use-package avy
  :attach (meow)
  (bind meow-normal-state-keymap
	(bind-command "avy"
	  "a" #'avy-goto-char))
  
  :attach (isearch)
  (bind isearch-mode-map
	"M-a" #'avy-isearch)

  :init
  (setq avy-style 'de-bruijn
	avy-all-windows t)

  :config
  (defun avy-goto-char-bg-first ()
    (interactive)
    (let ((avy-background t)) (avy--make-backgrounds (avy-window-list)))
    (call-interactively #'avy-goto-char)))
