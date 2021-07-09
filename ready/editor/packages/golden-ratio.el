;;; golden-ratio.el -*- lexical-binding: t; -*-

(use-package golden-ratio
  :demand
  :config
  (after! which-key
    (add-to-list 'golden-ratio-inhibit-functions
                 (lambda ()
                   (and which-key--buffer
                        (window-live-p (get-buffer-window which-key--buffer))))))
  (golden-ratio-mode))
