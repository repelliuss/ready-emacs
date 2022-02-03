;;; open.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar rps/open-map (make-sparse-keymap))
  :prefix "o"
  "e" #'eshell)

(provide 'rps/editor/open)
