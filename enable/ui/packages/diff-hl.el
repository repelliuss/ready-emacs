;;; diff-hl.el -*- lexical-binding: t; -*-

(use-package diff-hl
  :init
  (setq diff-hl-disable-on-remote t
	diff-hl-draw-borders nil)

  (add-hook 'prog-mode-hook #'turn-on-diff-hl-mode)
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode-unless-remote)
 
  :config
  ;; TODO: bind to local leader
  (bind prog-mode-map
	(bind-prefix "d"
	  "RET" #'diff-hl-show-hunk
	  "[" #'diff-hl-previous-hunk
	  "]" #'diff-hl-next-hunk
	  "{" #'diff-hl-show-hunk-previous
	  "}" #'diff-hl-show-hunk-next
	  "r" #'diff-hl-revert-hunk
	  "g" #'diff-hl-diff-goto-hunk
	  "s" #'diff-hl-stage-current-hunk))
  
  :extend (meow)
  (add-hook 'diff-hl-inline-popup-transient-mode-hook
	    (defun diff-hl-transient-override-meow ()
	      (if diff-hl-inline-popup-transient-mode
		  (meow-insert)
		(meow-insert-exit))))
 
  :extend (magit)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))
