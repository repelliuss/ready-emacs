;;; magit.el -*- lexical-binding: t; -*-

(use-package magit
  :attach (rps/editor/open)
  (bind rps/open-map
	"g" #'magit-status
	"G" #'magit-dispatch)
  
  :init
  (bind prog-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "g" #'magit-file-dispatch))
  
  (setq magit-define-global-key-bindings nil)
  
  :config
  (add-hook 'git-commit-mode-hook (defun meow-insert-at-eol ()
				    (end-of-line)
				    (meow-insert))))
