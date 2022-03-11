;;; web.el -*- lexical-binding: t; -*-

(defun html-try-get-title-this-buffer ()
  (save-excursion
    (goto-char (point-min))
    (re-search-forward "<title[^>]*>\\([^<]*\\)</title>" nil t 1)
    (substring-no-properties (match-string 1))))

(defun web-copy-html-of-url (url)
  (interactive (list (read-string "URL: ")))
  (let ((tmp-name (make-temp-name "web-copy-html-of-url#")))
    (url-copy-file url tmp-name)
    (with-current-buffer (find-file-noselect tmp-name)
      (let ((title (concat (kill-new (or (html-try-get-title-this-buffer)
					 (read-string "Title: "))) ".html")))
	(rename-file tmp-name title)
	(message "HTML of url is copied to '%s'" title)))))
