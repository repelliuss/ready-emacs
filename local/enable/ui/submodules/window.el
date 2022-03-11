;;; window.el -*- lexical-binding: t; -*-

(setq window-divider-default-right-width 12
      window-divider-default-bottom-width 1)
(setq window-divider-default-places t)

(defun window-divider-blend-with-background (&rest _)
  (interactive)
  (let ((bg (face-background 'default)))
    (dolist (face '(window-divider
		    window-divider-last-pixel
		    window-divider-first-pixel))
      (set-face-foreground face bg))))

(setq display-buffer-base-action '((display-buffer-reuse-window
				    display-buffer-reuse-mode-window
				    display-buffer-pop-up-window
				    display-buffer-same-window) . nil))

(advice-add #'enable-theme :after #'window-divider-blend-with-background)

(window-divider-blend-with-background)

(window-divider-mode 1)


