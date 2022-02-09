;;; open.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/open-map (make-sparse-keymap))
  "e" #'eshell)
 (rps/leader-map
  "o" rps/open-map))

