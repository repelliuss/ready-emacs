;;; org.el -*- lexical-binding: t; -*-

(with-eval-after-load '@web
  (defun @org-insert-link-html (url)
    (interactive (list (read-string "URL: ")))
    (@web-download-async url
			 (lambda (file-path title)
			   (org-insert-link
			    nil
			    (concat "html:" file-path)
			    title)))))

(use-package htmlize)

(use-package org
  :init
  (setq org-directory (concat home-dir "org/")
	org-id-locations-file (concat org-directory ".org-id-locations")
	org-archive-location (concat org-directory "archive/archive_%s::datetree/")
	org-persist-directory (concat cache-dir "org-persist/")
	org-id-link-to-org-use-id t
	org-ellipsis "…"
	org-extend-today-until 2)

  (make-directory (concat org-directory "archive/") 'with-parents)

  :config
  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode))

