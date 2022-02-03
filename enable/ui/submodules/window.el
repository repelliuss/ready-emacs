;;; window.el -*- lexical-binding: t; -*-

(setq window-divider-default-right-width 12)
(setq window-divider-default-places 'right-only)

(defun window-divider-blend-with-background (&rest _)
  (interactive)
  (let ((bg (face-background 'default)))
    (dolist (face '(window-divider
		    window-divider-last-pixel
		    window-divider-first-pixel))
      (set-face-foreground face bg)))
  (message "called"))

(advice-add #'enable-theme :after #'window-divider-blend-with-background)

(window-divider-blend-with-background)

(window-divider-mode 1)


