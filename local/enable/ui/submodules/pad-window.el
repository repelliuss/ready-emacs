;;; pad-window.el -*- lexical-binding: t; -*-

(defun window-divider-blend-with-background (&rest _)
  (interactive)
  (let ((bg (face-background 'default)))
    (dolist (face '(window-divider
		    window-divider-last-pixel
		    window-divider-first-pixel))
      (set-face-foreground face bg))))

(@setup nil
  (:option window-divider-default-right-width 8
	   window-divider-default-bottom-width 1
	   window-divider-default-places t)
  (window-divider-mode 1)
  (advice-add #'enable-theme :after #'window-divider-blend-with-background)
  (@funcall-consider-daemon #'window-divider-blend-with-background) )




