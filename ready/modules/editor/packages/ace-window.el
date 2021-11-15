;;; ace-window.el -*- lexical-binding: t; -*-

(use-package ace-window
  :after (meow)
  :general
  (meow-leader-keymap
   :prefix "w"
   "w" #'ace-window
   "f" #'aw-flip-window)
  :extend (golden-ratio)
  (advice-add #'ace-window :after #'golden-ratio))
