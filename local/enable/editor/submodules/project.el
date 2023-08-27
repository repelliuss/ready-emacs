;;; project.el -*- lexical-binding: t; -*-

(set-keymap-parent @keymap-project project-prefix-map)

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("p$" . "prefix") . (nil . "project")))))
