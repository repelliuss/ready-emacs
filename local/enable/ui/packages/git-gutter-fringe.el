;;; git-gutter-fringe.el -*- lexical-binding: t; -*-

(use-package git-gutter-fringe
  :init
  (add-hook 'prog-mode-hook
	    (defun git-gutter-mode-maybe ()
	      (let ((path (buffer-file-name (buffer-base-buffer))))
		(if (and path
			 (not (file-remote-p path))
			 (vc-backend path))
		    (git-gutter-mode 1)
		  (message "git-gutter-fringe is bypassed"))))))
