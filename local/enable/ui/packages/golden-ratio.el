;;; golden-ratio.el -*- lexical-binding: t; -*-

(setup golden-ratio
  (:set golden-ratio-recenter t)
  
  (:when-loaded
    (:after-feature which-key
      (:set (prepend golden-ratio-inhibit-functions)
            (lambda ()
              (and which-key--buffer
                   (window-live-p (get-buffer-window which-key--buffer))))))))

(advice-add #'ace-window :after #'~golden-ratio-only-if-less-than-three-window)
(defvar ~golden-ratio-dynamic-last-action nil)

(defun ~golden-ratio-only-if-less-than-three-window (&rest _)
  (if (< 2 (let ((count 0))
             (dolist (w (window-list-1))
               (if (not (window-parameter w 'window-side))
                   (setq count (1+ count))))
             count))
      (progn
        (unless (eq ~golden-ratio-dynamic-last-action 'balance)
          (balance-windows)
          (setq ~golden-ratio-dynamic-last-action 'balance)))
    (call-interactively #'golden-ratio)
    (setq ~golden-ratio-dynamic-last-action 'golden)))
