;;; keys.el -*- lexical-binding: t; -*-

(bind
 ((current-global-map)
  "C-/" (setq rps/leader-map (make-sparse-keymap)))
 (rps/leader-map
  "/" (setq rps/local-leader-map (make-sparse-keymap))))
