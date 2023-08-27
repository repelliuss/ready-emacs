;;; edit.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/edit-map (make-sparse-keymap))
  "e" #'pp-eval-last-sexp)
 (rps/leader-map
  "e" rps/edit-map))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("e$" . "prefix") . (nil . "edit")))))
