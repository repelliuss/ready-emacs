;;; search.el -*- lexical-binding: t; -*-

(cfg emacs
  (:bind rps-keymap-search
         "s" #'isearch-forward-regexp
         "o" #'occur
         "O" (cons "Search occur in multi files" #'multi-occur)
         "d" (cons "Search file in Dired" #'find-name-dired)
         "F" #'locate
         "D" #'find-grep-dired
         "l" #'keep-lines
         "L" #'flush-lines))
