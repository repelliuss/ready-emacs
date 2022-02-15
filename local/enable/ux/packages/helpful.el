;;; helpful.el -*- lexical-binding: t; -*-

(use-package helpful
  :init
  (bind
   ((current-global-map)
    [remap describe-function] #'helpful-callable
    [remap describe-key] #'helpful-key
    [remap describe-variable] #'helpful-variable)
   (help-map
    "." #'helpful-at-point)))

