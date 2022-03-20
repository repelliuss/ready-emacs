;;; helpful.el -*- lexical-binding: t; -*-

(use-package helpful
  :init
  (bind
   ((current-global-map)
    [remap describe-function] #'helpful-callable
    [remap describe-key] #'helpful-key
    [remap describe-variable] #'helpful-variable)
   (help-map
    "." #'helpful-at-point)
   (helpful-mode-map
    "j" #'next-line
    "k" #'previous-line
    "<" #'scroll-down-command
    ">" #'scroll-up-command)))

