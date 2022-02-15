;;; keys.el -*- lexical-binding: t; -*-

(defcustom leader-prefix "SPC "
  "Leader prefix.")

(defcustom local-leader-prefix "SPC SPC "
  "Local leader prefix.")

(bind (current-global-map)
      "C-/" (setq rps/leader-map (make-sparse-keymap)))

(defun keys-make-local-prefix (&optional key)
  (concat local-leader-prefix key))
