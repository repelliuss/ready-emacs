;;; flymake.el -*- lexical-binding: t; -*-

(defun rps-flymake-show-flymake-eldoc-function ()
  (interactive)
  (message (mapconcat #'flymake-diagnostic-text (flymake-diagnostics (point)) "\n")))

(cfg flymake
  (:opt flymake-fringe-indicator-position nil)

  (:after consult
    (:bind rps-keymap-normal
           "!" #'consult-flymake)))
