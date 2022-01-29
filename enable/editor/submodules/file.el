;;; file.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar rps/file-map (make-sparse-keymap))
  :prefix "f"
  "s" #'save-buffer
  "d" #'delete-buffer-file)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("f$" . "prefix") . (nil . "file"))))

(defun delete-buffer-file (buffer)
  (interactive (list (current-buffer)))
  (if-let ((path (buffer-file-name buffer)))
      (progn
	(delete-file path 'trash-t)
	(remove-files-from-all-caches path)
	(kill-buffer-in-all-windows buffer 'dont-save-t))
    (message "Buffer doesn't visit a file")))

(defun kill-buffer-in-all-windows (buffer &optional dont-save)
  "Kill BUFFER globally and ensure all windows previously showing this buffer
have switched to a real buffer or the fallback buffer.

If DONT-SAVE, don't prompt to save modified buffers (discarding their changes)."
  (interactive
   (list (current-buffer) current-prefix-arg))
  (cl-assert (bufferp buffer) t)
  (when (and (buffer-modified-p buffer) dont-save)
    (with-current-buffer buffer
      (set-buffer-modified-p nil)))
  (let ((windows (get-buffer-window-list buffer)))
    (kill-buffer buffer)
    (dolist (window (cl-remove-if-not #'window-live-p windows))
      (with-selected-window window
	(when (equal buffer (window-buffer))
	  (previous-buffer))))))

(defun remove-files-from-all-caches (&rest files)
  "Ensure FILES are updated in `recentf', `magit' and `save-place'."
  (let (toplevels)
    (dolist (file files)
      (when (featurep 'vc)
        (vc-file-clearprops file)
        (when-let (buffer (get-file-buffer file))
          (with-current-buffer buffer
            (vc-refresh-state))))
      (when (featurep 'magit)
        (when-let (default-directory (magit-toplevel (file-name-directory file)))
          (cl-pushnew default-directory toplevels)))
      (unless (file-readable-p file)
        (when (bound-and-true-p recentf-mode)
          (recentf-remove-if-non-kept file))
        (when (and (bound-and-true-p projectile-mode)
                   (doom-project-p)
                   (projectile-file-cached-p file (doom-project-root)))
          (projectile-purge-file-from-cache file))))
    (dolist (default-directory toplevels)
      (magit-refresh))
    (when (bound-and-true-p save-place-mode)
      (save-place-forget-unreadable-files))))

(provide 'rps/editor/file)
