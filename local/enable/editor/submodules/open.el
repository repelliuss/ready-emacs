;;; open.el -*- lexical-binding: t; -*-

(bind ~keymap-open
      "e" #'eshell)

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("o$" . "prefix") . (nil . "open")))))

