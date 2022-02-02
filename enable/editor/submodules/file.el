;;; file.el -*- lexical-binding: t; -*-

(general-def
  :keymaps (defvar rps/file-map (make-sparse-keymap))
  :prefix "f"
  "s" #'save-buffer
  "d" #'delete-buffer-file
  "r" #'recentf-open-files
  "m" #'move-buffer-file
  "c" #'copy-buffer-file
  "F" #'sudo-find-file
  "B" #'sudo-buffer-file
  "S" #'sudo-save-file)

(setq delete-by-moving-to-trash t)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("f$" . "prefix") . (nil . "file"))))

(defun act-buffer-file (buffer new-path act)
  (if-let ((path (buffer-file-name (current-buffer))))
      (progn
	(funcall act path new-path)
	(find-file new-path))
    (error "Buffer doesn't visit a file")))

(defun move-buffer-file (buffer new-path)
    (interactive (list (current-buffer)
		       (read-file-name "Move to: ")))
    (act-buffer-file buffer new-path #'rename-file))

(defun copy-buffer-file (buffer new-path)
    (interactive (list (current-buffer)
		       (read-file-name "Copy to: ")))
    (act-buffer-file buffer new-path #'copy-file))

(defun delete-buffer-file (buffer)
  (interactive (list (current-buffer)))
  (if-let ((path (buffer-file-name buffer)))
      (when (y-or-n-p "Are you sure to delete this file?")
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
      (when (and (not (file-readable-p file))
		 (bound-and-true-p file))
	(recentf-remove-if-non-kept file)))
    (dolist (default-directory toplevels)
      (magit-refresh))
    (when (bound-and-true-p save-place-mode)
      (save-place-forget-unreadable-files))))

(defun get-sudo-file-path (file)
  (let ((host (or (file-remote-p file 'host) "localhost")))
    (concat "/" (when (file-remote-p file)
                  (concat (file-remote-p file 'method) ":"
                          (if-let (user (file-remote-p file 'user))
                              (concat user "@" host)
                            host)
                          "|"))
            "sudo:root@" host
            ":" (or (file-remote-p file 'localname)
                    file))))

(defun sudo-find-file (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (find-file (get-sudo-file-path file)))

(defun sudo-buffer-file ()
  "Open the current file as root."
  (interactive)
  (find-file
   (get-sudo-file-path
    (or buffer-file-name
        (when (or (derived-mode-p 'dired-mode)
                  (derived-mode-p 'wdired-mode))
          default-directory)))))

(defun sudo-save-buffer ()
  "Save this file as root."
  (interactive)
  (let ((file (get-sudo-file-path buffer-file-name)))
    (if-let (buffer (find-file-noselect file))
        (let ((origin (current-buffer)))
          (copy-to-buffer buffer (point-min) (point-max))
          (unwind-protect
              (with-current-buffer buffer
                (save-buffer))
            (unless (eq origin buffer)
              (kill-buffer buffer))
            (with-current-buffer origin
              (revert-buffer t t))))
      (user-error "Unable to open %S" file))))

(provide 'rps/editor/file)
