;;; frame-padding.el -*- lexical-binding: t; -*-

(defgroup frame-padding nil
  "frame-padding package group.")

(defcustom frame-padding-size 70
  "Size of rectangle padding's one side."
  :initialize #'custom-initialize-default
  :set #'frame-padding--put)

(defun frame-padding--put (&optional sym val)
  (when sym (set-default sym val))
  (set-frame-parameter nil 'internal-border-width
		       frame-padding-size))

(defun frame-padding--remove ()
  (set-frame-parameter nil 'internal-border-width
		       (or (alist-get 'internal-border-width
				      default-frame-alist) 0)))

(defun frame-padding-increase (&optional by)
  (interactive)
  (frame-padding--put 'frame-padding-size
		      (+ frame-padding-size (or by 10))))

(defun frame-padding-decrease (&optional by)
  (interactive)
  (frame-padding--put 'frame-padding-size
		      (- frame-padding-size (or by 10))))

(defun frame-padding--turn-off ()
  (frame-padding-global-mode -1))

;;;###autoload
(defun frame-padding-hold-on-to (mode-function &rest let-hooks)
  (advice-add mode-function :after
	      (lambda (mode-arg)
		(frame-padding-global-mode mode-arg)
		(if frame-padding-global-mode
		    (dolist (hook (cons 'kill-buffer-hook let-hooks))
		      (add-hook hook #'frame-padding--turn-off 0 'local))))))

;;;###autoload
(define-minor-mode frame-padding-global-mode
  "Global mode to put rectangle padding to frame."
  :global t
  :keymap (make-sparse-keymap)
  (if frame-padding-global-mode
      (frame-padding--put)
    (frame-padding--remove)))

(provide 'frame-padding)

(setup frame-padding
  (:elpaca nil)
  (:after-feature org-tree-slide (frame-padding-hold-on-to #'org-tree-slide-mode))
  (:bind ~keymap-toggle "p" #'frame-padding-global-mode))
