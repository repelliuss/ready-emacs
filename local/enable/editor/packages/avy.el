;;; avy.el -*- lexical-binding: t; -*-

(setup avy
  (:bind ~keymap-normal
         (:autoload :avy
           "a" #'~avy-goto-char-bg-first))

  (:after-feature isearch
    (:bind isearch-mode-map
           "M-a" #'avy-isearch))

  (:set avy-style 'de-bruijn
        avy-all-windows nil)

  (defun ~avy-goto-char-bg-first ()
    (interactive)
    (let ((avy-background t)) (avy--make-backgrounds (avy-window-list)))
    (call-interactively #'avy-goto-char)))
