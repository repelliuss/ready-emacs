;;; org.el -*- lexical-binding: t; -*-

(use-package org
  :init
  (setq org-directory (concat home-dir "org/")
	org-id-locations-file (concat org-directory ".org-id-locations")
	org-archive-location (concat org-directory "archive/%s_archive::")
	org-id-link-to-org-use-id t
	org-ellipsis "…"
	org-extend-today-until 2)

  :config
  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode))

