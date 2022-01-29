;;; buffer.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar rps/buffer-map (make-sparse-keymap))
  :prefix "b"
  "k" #'kill-current-buffer
  "K" #'kill-all-buffers
  "]" #'next-buffer
  "[" #'previous-buffer
  "r" #'revert-buffer
  "i" #'ibuffer
  "c" #'clone-indirect-buffer-other-window
  "C" #'clone-indirect-buffer
  "S" #'save-all-possible-buffers
  "n" narrow-map
  "z" #'bury-buffer)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("b$" . "prefix") . (nil . "buffer"))))

(defun kill-all-buffers (&optional buffer-list interactive)
  "Kill all buffers and closes their windows.

If the prefix arg is passed, doesn't close windows and only kill buffers that
belong to the current project."
  (interactive
   (list (if current-prefix-arg
             (project-buffers)
           (buffer-list))
         t))
  (if (null buffer-list)
      (message "No buffers to kill")
    (save-some-buffers)
    (delete-other-windows)
    (mapc #'kill-buffer buffer-list)
    (message "Killed %d buffers"
	     (- (length buffer-list)
		(length (cl-remove-if-not #'buffer-live-p buffer-list))))))

(defun save-all-possible-buffers ()
  (interactive)
  (let ((saved-count 0)) 
    (save-some-buffers t
                       #'(lambda ()
                           (if (and (not buffer-read-only)
				    (buffer-file-name))
			       (cl-incf saved-count))))
    (message "Saved %d buffers" saved-count)))

(provide 'rps/editor/buffer)
