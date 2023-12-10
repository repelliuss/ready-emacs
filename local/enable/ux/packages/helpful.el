;;; helpful.el -*- lexical-binding: t; -*-

(setup helpful
  (:bind (help-map
          "." #'helpful-at-point)
         (~keymap-leader
          "h" help-map))
  (:when-loaded
    (:bind "<" #'scroll-down-command
           ">" #'scroll-up-command))
  
  (:with-function describe-function
    (:advice :override #'helpful-callable))
  
  (:with-function describe-key
    (:advice :override #'helpful-key))
  
  (:with-function describe-variable
    (:advice :override #'helpful-variable))

  (:after-feature which-key
    (:set (prepend which-key-replacement-alist) '(("h$" . "prefix") . (nil . "help")))))


