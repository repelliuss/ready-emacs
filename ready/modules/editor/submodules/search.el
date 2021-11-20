;;; search.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar ready/search-map (make-sparse-keymap))
  :prefix "s"
  "s" #'isearch-forward-regexp
  "o" #'occur
  "O" #'multi-occur
  "f" #'find-name-dired
  "F" #'locate
  "g" #'find-grep-dired
  "l" #'flush-lines
  "L" #'keep-lines)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("s$" . "prefix") . (nil . "search"))))

(provide 'ready/editor/search)
