;;; magit.el -*- lexical-binding: t; -*-

(use-package magit
  :attach (meow)
  (general-def 'meow-leader-keymap
    "g" #'magit-status))