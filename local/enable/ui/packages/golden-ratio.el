;;; golden-ratio.el -*- lexical-binding: t; -*-

(setup golden-ratio
  (:set golden-ratio-recenter t)
  
  (:when-loaded
    (:after-feature which-key
      (:set (prepend golden-ratio-inhibit-functions)
            (lambda ()
              (and which-key--buffer
                   (window-live-p (get-buffer-window which-key--buffer)))))))

  (:with-hook window-state-change-hook
    (:hook ~golden-ratio-only-if-less-than-three-window)))

(defun ~golden-ratio-only-if-less-than-three-window ()
  (if (< 2 (length (window-list-1)))
      (progn
        (with-eval-after-load #'ace-window
          (advice-remove #'ace-window #'golden-ratio))
        (golden-ratio-mode -1)
        (balance-windows))
    (with-eval-after-load #'ace-window
      (advice-add #'ace-window :after #'golden-ratio))
    (golden-ratio-mode 1)))
