;;; file.el -*- lexical-binding: t; -*-

(cfg emacs
  (:bind rps-keymap-file
         "s" #'save-buffer
         "d" #'rps-file-delete
         "r" #'recentf-open-files
         "m" #'rps-file-move
         "c" #'rps-file-copy
         "F" #'rps-file-sudo-find
         "B" #'rps-file-sudo
         "S" #'rps-file-sudo-save)

  (:opt delete-by-moving-to-trash t)

  (global-auto-revert-mode 1))

(defun rps-file-act-on-buffer (buffer new-path act)
  (if-let* ((path (buffer-file-name buffer)))
      (progn
	    (make-directory (file-name-directory new-path) 'with-parents)
	    (funcall act path new-path)
	    (find-file new-path)
	    (kill-buffer buffer))
    (error "Buffer doesn't visit a file")))

(defun rps-file-move (buffer new-path)
  (interactive (list (current-buffer)
		             (read-file-name "Move to: ")))
  (rps-file-act-on-buffer buffer new-path #'rename-file))

(defun rps-file-copy (buffer new-path)
  (interactive (list (current-buffer)
		             (read-file-name "Copy to: ")))
  (rps-file-act-on-buffer buffer new-path #'copy-file))

(defun rps-file-delete (buffer)
  (interactive (list (current-buffer)))
  (if-let* ((path (buffer-file-name buffer)))
      (when (y-or-n-p "Are you sure to delete this file?")
	    (delete-file path 'trash)
	    (rps-file-remove-from-cache path)
	    (rps-file-kill-windows buffer 'dont-save))
    (message "Buffer doesn't visit a file")))

(defun rps-file-kill-windows (buffer &optional dont-save)
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

(defun rps-file-remove-from-cache (&rest files)
  "Ensure FILES are updated in `recentf', `magit' and `save-place'."
  (let (toplevels)
    (dolist (file files)
      (when (featurep 'vc)
        (vc-file-clearprops file)
        (when-let* ((buffer (get-file-buffer file)))
          (with-current-buffer buffer
            (vc-refresh-state))))
      (when (featurep 'magit)
        (when-let* (default-directory (magit-toplevel (file-name-directory file)))
          (cl-pushnew default-directory toplevels)))
      (when (and (not (file-readable-p file))
		         (bound-and-true-p file))
	    (recentf-remove-if-non-kept file)))
    (dolist (default-directory toplevels)
      (magit-refresh))
    (when (bound-and-true-p save-place-mode)
      (save-place-forget-unreadable-files))))

(defun rps-file-sudo-path (file)
  (let ((host (or (file-remote-p file 'host) "localhost")))
    (concat "/" (when (file-remote-p file)
                  (concat (file-remote-p file 'method) ":"
                          (if-let* ((user (file-remote-p file 'user)))
                              (concat user "@" host)
                            host)
                          "|"))
            "sudo:root@" host
            ":" (or (file-remote-p file 'localname)
                    file))))

(defun rps-file-sudo-find (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (find-file (rps-file-sudo-path file)))

(defun rps-file-sudo ()
  "Open the current file as root."
  (interactive)
  (find-file
   (rps-file-sudo-path
    (or buffer-file-name
        (when (or (derived-mode-p 'dired-mode)
                  (derived-mode-p 'wdired-mode))
          default-directory)))))

(defun rps-file-sudo-save ()
  "Save this file as root."
  (interactive)
  (let ((file (rps-file-sudo-path buffer-file-name)))
    (if-let* (buffer (find-file-noselect file))
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


(add-hook 'find-file-not-found-functions
          (defun doom-create-missing-directories-h ()
            "Automatically create missing directories when creating new files."
            (unless (file-remote-p buffer-file-name)
              (let ((parent-directory (file-name-directory buffer-file-name)))
                (and (not (file-directory-p parent-directory))
                     (y-or-n-p (format "Directory `%s' does not exist! Create it?"
                                       parent-directory))
                     (progn (make-directory parent-directory 'parents)
                            t))))))
