;;; search.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/search-map (make-sparse-keymap))
  "s" #'isearch-forward-regexp
  "o" #'occur
  "O" #'multi-occur
  "f" #'find-name-dired
  "F" #'locate
  "g" #'find-grep-dired
  "l" #'keep-lines
  "L" #'flush-lines)
 (rps/leader-map
  "s" rps/search-map))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("s$" . "prefix") . (nil . "search"))))

(provide 'rps/editor/search)
