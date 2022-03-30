;;; keys.el -*- lexical-binding: t; -*-

(defcustom leader-prefix "SPC "
  "Leader prefix.")

(defcustom local-leader-prefix "C-c"
  "Local leader prefix.")

(bind (current-global-map)
      "S-SPC" (setq rps/leader-map (make-sparse-keymap)))

(defun keys-make-local-prefix (&optional key)
  (concat local-leader-prefix (if key " ") key))
