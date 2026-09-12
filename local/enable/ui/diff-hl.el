;;; diff-hl.el -*- lexical-binding: t; -*-

(cfg-pkg diff-hl
  (:bind prog-mode-map
	     (:locally "d"
    	           "RET" #'diff-hl-show-hunk
	               "[" #'diff-hl-previous-hunk
	               "]" #'diff-hl-next-hunk
	               "{" #'diff-hl-show-hunk-previous
	               "}" #'diff-hl-show-hunk-next
	               "r" #'diff-hl-revert-hunk
	               "g" #'diff-hl-diff-goto-hunk
	               "s" #'diff-hl-stage-current-hunk))

  (:opt diff-hl-disable-on-remote t
	    diff-hl-draw-borders nil)

  (:hook-to 'prog-mode-hook #'turn-on-diff-hl-mode)
  (:hook-to 'dired-mode-hook #'diff-hl-dired-mode-unless-remote)

  (:after meow
    (:hook-to 'diff-hl-inline-popup-transient-mode-hook #'rps-diff-hl-transient-override-meow))

  (:after magit
    (:hook-to 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

(defun rps-diff-hl-transient-override-meow ()
  (if diff-hl-inline-popup-transient-mode
	  (meow-insert)
	(meow-insert-exit)))
