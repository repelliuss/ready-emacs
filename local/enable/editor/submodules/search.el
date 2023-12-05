;;; search.el -*- lexical-binding: t; -*-

(bind $keymap-search
      "s" #'isearch-forward-regexp
      "o" #'occur
      "O" (cons "Search occur in multi files" #'multi-occur)
      "f" (cons "Search file in Dired" #'find-name-dired)
      "F" #'locate
      "g" #'find-grep-dired
      "l" #'keep-lines
      "L" #'flush-lines)

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("s$" . "prefix") . (nil . "search")))))
