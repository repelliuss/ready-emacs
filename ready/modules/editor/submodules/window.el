;;; window.el -*- lexical-binding: t; -*-

(general-def
 :keymaps (defvar rdy/window-map (make-sparse-keymap))
 :prefix "w"
 "h" #'windmove-left
 "j" #'windmove-down
 "k" #'windmove-up
 "l" #'windmove-right
 "H" #'windmove-swap-states-left
 "J" #'windmove-swap-states-down
 "K" #'windmove-swap-states-up
 "L" #'windmove-swap-states-right
 "d" #'delete-window
 "D" #'delete-other-windows
 "s" #'split-window-below
 "v" #'split-window-right)

(after! which-key
  (add-to-list 'which-key-replacement-alist '(("w$" . "prefix") . (nil . "Window")))
  (add-to-list 'which-key-replacement-alist '(("w .$" . "\\(?:-\\(?:states\\|windows?\\)\\|wind\\(?:ow\\)?\\)") . (nil . ""))))

(provide 'rdy/window/editor)
