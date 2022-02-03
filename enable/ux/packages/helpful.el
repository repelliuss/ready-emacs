;;; helpful.el -*- lexical-binding: t; -*-

(use-package helpful
  :general
  ([remap describe-function] #'helpful-callable
   [remap describe-key] #'helpful-key
   [remap describe-variable] #'helpful-variable)
  (help-map
   "." #'helpful-at-point))

