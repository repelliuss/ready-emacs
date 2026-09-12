;;; buffer.el -*- lexical-binding: t; -*-

(cfg emacs
  (:bind rps-keymap-buffer
         "k" #'kill-current-buffer
         "K" #'rps-buffer-kill-all
         "]" #'next-buffer
         "[" #'previous-buffer
         "r" #'revert-buffer-quick
         "i" #'ibuffer
         "c" #'clone-indirect-buffer-other-window
         "C" #'clone-indirect-buffer
         "S" #'rps-buffer-save-all
         "n" narrow-map
         "z" #'bury-buffer)
  (:opt display-buffer-base-action '((display-buffer-reuse-window
				                      display-buffer-reuse-mode-window
				                      display-buffer-pop-up-window
				                      display-buffer-same-window) . ((window-width . 0))))
  (:prepend* display-buffer-alist '(("\\*compilation\\*" .
				                     ((display-buffer-in-side-window) .
				                      ((side . bottom)
				                       (dedicated . t)))))))

(defun rps-buffer-kill-all (&optional buffer-list interactive)
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
    (mapc (lambda (buffer) (ignore-errors (kill-buffer-if-not-modified buffer))) buffer-list)
    (message "Killed %d buffers"
	         (- (length buffer-list)
		        (length (cl-remove-if-not #'buffer-live-p buffer-list))))))

(defun rps-buffer-save-all ()
  (interactive)
  (let ((saved-count 0))
    (save-some-buffers t
                       #'(lambda ()
                           (if (and (not buffer-read-only)
				                    (buffer-file-name))
			                   (cl-incf saved-count))))
    (message "Saved %d buffers" saved-count)))

