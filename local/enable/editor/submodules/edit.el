;;; edit.el -*- lexical-binding: t; -*-

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("e$" . "prefix") . (nil . "edit")))))
