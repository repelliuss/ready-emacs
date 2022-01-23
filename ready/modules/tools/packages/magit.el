;;; magit.el -*- lexical-binding: t; -*-

(use-package magit
  :init
  (with-eval-after-load 'meow
    (general-def 'meow-leader-keymap
      "g" #'magit-status)))
