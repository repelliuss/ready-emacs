;;; toggle.el -*- lexical-binding: t; -*-

(cfg emacs
  (:bind rps-keymap-toggle
         "r" #'rps-toggle-read-only-mode
         "s" #'toggle-frame-fullscreen))

(defun rps-toggle-read-only-mode ()
  (interactive)
  (if buffer-read-only
      (read-only-mode -1)
    (read-only-mode 1)))
