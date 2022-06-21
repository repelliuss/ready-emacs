;;; note.el -*- lexical-binding: t; -*-

(bind rps/leader-map
      "n" (setq rps/note-map (make-sparse-keymap)))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("n$" . "prefix") . (nil . "note"))))
