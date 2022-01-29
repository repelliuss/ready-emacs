;;; ripgrep.el -*- lexical-binding: t; -*-

(use-package consult
  :straight nil
  :after (rps/editor/search)
  :general
  (rps/search-map
   "s g" #'consult-ripgrep))

;; TODO: add checks for ripgrep and fd executables
