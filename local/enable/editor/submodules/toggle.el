;;; toggle.el -*- lexical-binding: t; -*-

(bind ~keymap-toggle
      "r" #'~toggle-read-only-mode)

(defun ~toggle-read-only-mode ()
  (interactive)
  (if buffer-read-only
      (read-only-mode -1)
    (read-only-mode 1)))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("t$" . "prefix") . (nil . "toggle")))))

