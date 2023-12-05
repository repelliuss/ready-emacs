;;; file.el -*- lexical-binding: t; -*-

(bind $keymap-file
      "s" #'save-buffer
      "d" #'$file-delete
      "r" #'recentf-open-files
      "m" #'$file-move
      "c" #'$file-copy
      "F" #'$file-sudo-find
      "B" #'$file-sudo
      "S" #'$file-sudo-save)

(setq delete-by-moving-to-trash t)

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend which-key-replacement-alist) '(("f$" . "prefix") . (nil . "file")))))

(defun $file-act-on-buffer (buffer new-path act)
  (if-let ((path (buffer-file-name buffer)))
      (progn
	(make-directory (file-name-directory new-path) 'with-parents)
	(funcall act path new-path)
	(find-file new-path)
	(kill-buffer buffer))
    (error "Buffer doesn't visit a file")))

(defun $file-move (buffer new-path)
    (interactive (list (current-buffer)
		       (read-file-name "Move to: ")))
    ($file-act-on-buffer buffer new-path #'rename-file))

(defun $file-copy (buffer new-path)
    (interactive (list (current-buffer)
		       (read-file-name "Copy to: ")))
    ($file-act-on-buffer buffer new-path #'copy-file))

(defun $file-delete (buffer)
  (interactive (list (current-buffer)))
  (if-let ((path (buffer-file-name buffer)))
      (when (y-or-n-p "Are you sure to delete this file?")
	(delete-file path 'trash)
	($file-remove-from-cache path)
	($file-kill-windows buffer 'dont-save))
    (message "Buffer doesn't visit a file")))

(defun $file-kill-windows (buffer &optional dont-save)
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

(defun $file-remove-from-cache (&rest files)
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

(defun $file-sudo-path (file)
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

(defun $file-sudo-find (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (find-file ($file-sudo-path file)))

(defun $file-sudo ()
  "Open the current file as root."
  (interactive)
  (find-file
   ($file-sudo-path
    (or buffer-file-name
        (when (or (derived-mode-p 'dired-mode)
                  (derived-mode-p 'wdired-mode))
          default-directory)))))

(defun $file-sudo-save ()
  "Save this file as root."
  (interactive)
  (let ((file ($file-sudo-path buffer-file-name)))
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
