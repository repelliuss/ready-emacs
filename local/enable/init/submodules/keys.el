;;; keys.el -*- lexical-binding: t; -*-

(defcustom leader-prefix "SPC "
  "Leader prefix.")

(defcustom local-leader-prefix "C-c"
  "Local leader prefix.")

(setq rps/normal-map (make-sparse-keymap))

(bind rps/normal-map
      "C-SPC" (setq rps/leader-map (make-sparse-keymap)))

(defun keys-make-local-prefix (&optional key)
  (concat local-leader-prefix (if key " ") key))
