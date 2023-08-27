;;; toggle.el -*- lexical-binding: t; -*-

(bind
 ((setq rps/toggle-map (make-sparse-keymap))
  "r" #'toggle-read-only-mode)
 (rps/leader-map
  "t" rps/toggle-map))

(defun toggle-read-only-mode ()
  (interactive)
  (if buffer-read-only
      (read-only-mode -1)
    (read-only-mode 1)))

(setup which-key
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("t$" . "prefix") . (nil . "toggle")))))

