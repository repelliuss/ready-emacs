;;; edit.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/edit-map (make-sparse-keymap))
  "e" #'pp-eval-last-sexp)
 (rps/leader-map
  "e" rps/edit-map))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("e$" . "prefix") . (nil . "edit"))))

(provide 'rps/editor/edit)
