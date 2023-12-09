;;; open.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/open-map (make-sparse-keymap))
  "e" #'eshell)
 (rps/leader-map
  "o" rps/open-map))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("o$" . "prefix") . (nil . "open")))))

