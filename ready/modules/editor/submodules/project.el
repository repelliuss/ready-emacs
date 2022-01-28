;;; project.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar ready/project-map (make-sparse-keymap))
  :prefix "p"
  "" project-prefix-map)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("p$" . "prefix") . (nil . "project"))))

(provide 'ready/editor/project)
