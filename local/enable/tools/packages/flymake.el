;;; flymake.el -*- lexical-binding: t; -*-

(setup flymake
  (:elpaca nil)
  (:set flymake-fringe-indicator-position nil)
  
  (defun ~flymake-show-flymake-eldoc-function ()
    (interactive)
    (message (mapconcat #'flymake-diagnostic-text (flymake-diagnostics (point)) "\n"))))
