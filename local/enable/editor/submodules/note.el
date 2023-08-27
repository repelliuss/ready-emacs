;;; note.el -*- lexical-binding: t; -*-

(bind rps/leader-map
      "n" (setq rps/note-map (make-sparse-keymap)))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("n$" . "prefix") . (nil . "note")))))
