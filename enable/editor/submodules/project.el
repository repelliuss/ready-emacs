;;; project.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar rps/project-map (make-sparse-keymap))
  :prefix "p"
  "" project-prefix-map)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("p$" . "prefix") . (nil . "project"))))

(provide 'rps/editor/project)
