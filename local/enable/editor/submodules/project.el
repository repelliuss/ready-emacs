;;; project.el -*- lexical-binding: t; -*-

(set-keymap-parent @keymap-project project-prefix-map)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("p$" . "prefix") . (nil . "project"))))
