;;; open.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/open-map (make-sparse-keymap))
  "e" #'eshell)
 (rps/leader-map
  "o" rps/open-map))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("o$" . "prefix") . (nil . "open"))))

(provide 'rps/editor/open)
