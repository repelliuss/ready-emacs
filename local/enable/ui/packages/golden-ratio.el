;;; golden-ratio.el -*- lexical-binding: t; -*-

(setup golden-ratio
  (:when-loaded
    (:after-feature which-key
      (:set (prepend golden-ratio-inhibit-functions)
            (lambda ()
              (and which-key--buffer
                   (window-live-p (get-buffer-window which-key--buffer)))))))

  (golden-ratio-mode 1))
