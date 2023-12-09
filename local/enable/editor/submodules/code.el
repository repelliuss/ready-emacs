;;; code.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/code-map (make-sparse-keymap))
  "c" #'project-compile)
 (rps/leader-map
  "c" rps/code-map))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("c$" . "prefix") . (nil . "code")))))
