;;; magit.el -*- lexical-binding: t; -*-

(use-package magit
  :config
  (add-hook 'git-commit-mode-hook (defun meow-insert-at-eol ()
				    (end-of-line)
				    (meow-insert)))
  
  :attach (meow)
  (meow-leader-define-key
   '("G" . magit-status)))
