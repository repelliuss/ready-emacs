;;; cursor.el -*- lexical-binding: t; -*-

;; The blinking cursor is distracting, but also interferes with cursor settings
;; in some minor modes that try to change it buffer-locally (like treemacs) and
;; can cause freezing for folks (esp on macOS) with customized & color cursors.
(blink-cursor-mode -1)

;; Don't stretch the cursor to fit wide characters, it is disorienting,
;; especially for tabs.
(setq x-stretch-cursor nil)

(defun cursor-hide ()
  (interactive)
  (run-at-time 1 nil (lambda () (setq-local cursor-type nil))))

