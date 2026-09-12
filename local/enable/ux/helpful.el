;;; helpful.el -*- lexical-binding: t; -*-

(cfg-pkg helpful
  (:bind
    ((:global-map)
     [remap describe-function] #'helpful-callable
     [remap describe-variable] #'helpful-variable
     [remap describe-key] #'helpful-key
     [remap describe-symbol] #'helpful-symbol
     [remap describe-command] #'helpful-command)
    (help-map
     "." #'helpful-at-point)
    (rps-keymap-leader
     "h" (cons "help" help-map)))

  (:after-this
    (:bind "M-i" #'imenu
           "<" #'scroll-down-command
           ">" #'scroll-up-command)))

