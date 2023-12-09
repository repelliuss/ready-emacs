;;; note.el -*- lexical-binding: t; -*-

(bind rps/leader-map
      "n" (setq rps/note-map (make-sparse-keymap)))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("n$" . "prefix") . (nil . "note")))))
