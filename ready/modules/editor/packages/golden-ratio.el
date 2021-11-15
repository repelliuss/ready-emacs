;;; golden-ratio.el -*- lexical-binding: t; -*-

(use-package golden-ratio
  :init
  (golden-ratio-mode 1)
  :extend (which-key)
  (add-to-list 'golden-ratio-inhibit-functions
               (lambda ()
                 (and which-key--buffer
                      (window-live-p (get-buffer-window which-key--buffer))))))
