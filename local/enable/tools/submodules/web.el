;;; web.el -*- lexical-binding: t; -*-

(require 'eww)

(defun @html-try-get-title-this-buffer ()
  (save-excursion
    (goto-char (point-min))
    (re-search-forward "<title[^>]*>\\([^<]*\\)</title>" nil t 1)
    (substring-no-properties (match-string 1))))

(setq @html-dir (expand-file-name "~/documents/html/"))
(make-directory @html-dir 'with-parents)

(defun @web--download-url-callback (status url dir)
  (unless (plist-get status :error)
    (let* ((obj (url-generic-parse-url url))
	   (path (directory-file-name (car (url-path-and-query obj))))
	   
	   (file (concat (eww-make-unique-file-name
			  (eww-decode-url-file-name (file-name-nondirectory path))
			  dir)
			 ".html")))
      (print (eww-decode-url-file-name (file-name-nondirectory path)))
      (goto-char (point-min))
      (re-search-forward "\r?\n\r?\n")
      (let ((coding-system-for-write 'no-conversion))
	(write-region (point) (point-max) file))
      (message "Saved %s" file)
      file)))

(defun @web--download-callback (status url dir callback-buffer &optional callbacks)
  (let* ((file-path (@web--download-url-callback status url dir))
	 (title (with-current-buffer (find-file-noselect file-path
							 'nowarn 'literally)
		  (@html-try-get-title-this-buffer))))
    (with-current-buffer callback-buffer
      (dolist (callback callbacks)
	(funcall callback file-path title)))))

(defun @web-download-async (url &rest callbacks)
  (interactive (list (read-string "URL: ")))
  (url-retrieve url #'@web--download-callback
		(list url @html-dir (current-buffer) callbacks)))

(provide '@web)
