;;; code.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/code-map (make-sparse-keymap))
  "c" #'project-compile)
 (rps/leader-map
  "c" rps/code-map))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("c$" . "prefix") . (nil . "code"))))
