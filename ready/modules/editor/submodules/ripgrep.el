;;; ripgrep.el -*- lexical-binding: t; -*-

(use-package consult
  :straight nil
  :after (ready/editor/search)
  :general
  (ready/search-map
   "s g" #'consult-ripgrep))

(provide 'ready/editor/ripgrep)

;; TODO: add checks for ripgrep and fd executables
