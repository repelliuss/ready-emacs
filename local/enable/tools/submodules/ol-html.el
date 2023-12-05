;;; ol-html.el -*- lexical-binding: t; -*-

(require 'ol)

(org-link-set-parameters "html"
			 :follow #'org-link-html-open
			 :complete #'org-link-html-complete
			 :export #'org-link-html-export)

(defcustom org-link-html-command #'eww-open-file
  "The Emacs command to be used to display html file."
  :group 'org-link)

(defcustom org-link-html-complete-default-dir nil
  "foo")

(defun org-link-html-open (path _)
  (funcall org-link-html-command path))

(defun org-link-html-export (path desc backend channel)
  (org-export-string-as (format "[[file:%s][%s]]" path desc)
			backend
			'body-only))

(defun org-link-html-read-file-name
    (read-file-name prompt &optional _ &rest args)
  (apply read-file-name prompt org-link-html-complete-default-dir args))

(defun org-link-html-complete (&optional arg)
  (unwind-protect
      (progn
	(advice-add #'read-file-name :around #'org-link-html-read-file-name)
	(concat "html" (substring (org-link-complete-file arg) 4)))
    (advice-remove #'read-file-name #'org-link-html-read-file-name)))

(provide 'ol-html)

(with-eval-after-load '$web
  (setq org-link-html-complete-default-dir $html-dir))
