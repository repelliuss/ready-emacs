;;; olivetti.el -*- lexical-binding: t; -*-

(setup olivetti
  (:hook-into org-tree-slide)
  (:set olivetti-body-width 128)
  (:bind ~keymap-toggle
         "o" (defun ~olivetti-toggle ()
               (interactive)
               (setq ~olivetti-mode-manual-p (not olivetti-mode))
               (call-interactively #'olivetti-mode)))
  (:with-hook window-state-change-hook
    (:hook
     (defun ~olivetti-only-if-solo-window ()
       (if (not (= 1 (length (window-list))))
           (unless (and (boundp '~olivetti-mode-manual-p) ~olivetti-mode-manual-p)
             (olivetti-mode -1))
         (olivetti-mode 1)))))
  (:with-function aw-split-window-fair
    (:advice :before
             (defun ~olivetti-run-if-solo-window-hook-early (&rest _)
               (olivetti-mode -1)))))
