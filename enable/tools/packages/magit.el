;;; magit.el -*- lexical-binding: t; -*-

(use-package magit
  :attach (meow)
  (meow-leader-define-key
   '("G" . magit-status)))
