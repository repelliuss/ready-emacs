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

;; TODO: all bind prefix calls to bind-local (mostly)

(defun bind-local (&optional key &rest bindings)
  (declare (indent 1))
  (if (eq (type-of key) (type-of (car bindings)))
      (progn
	(apply #'bind-prefix (keys-make-local-prefix key) bindings))
    (apply #'bind-prefix (keys-make-local-prefix) (cons key bindings))))
