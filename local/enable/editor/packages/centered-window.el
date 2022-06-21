;;; centered-window.el -*- lexical-binding: t; -*-

;; NOTE: I patched this package using straight 

(use-package centered-window
  :attach (org-tree-slide)
  (advice-add #'org-tree-slide-mode
	      :after
	      #'global-centered-window-mode)
  
  :config
  (setq cwm-use-vertical-padding t
	cwm-frame-internal-border 160)
  
  :extend (diff-hl)
  ;; this mode doesn't work great with fringes
  (advice-add #'centered-window-mode
	      :after
	      (lambda (&rest _)
		(if global-centered-window-mode
		    (run-with-timer 0 nil
				    (lambda ()
				      (diff-hl-mode -1)))
		  (if (buffer-modified-p)
		      (message "diff-hl may be disabled")
		    (run-with-timer 0 nil
				    (lambda ()
				      (revert-buffer-quick)
				      (diff-hl-update))))))))
