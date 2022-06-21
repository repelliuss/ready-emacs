;;; org.el -*- lexical-binding: t; -*-

(use-package org
  :init
  (setq org-directory "~/workspace/org/"
	org-misc-dir (concat org-directory "misc/")
	org-id-locations-file (concat org-misc-dir ".org-ids")
	org-id-link-to-org-use-id t
	org-ellipsis "…"
	org-archive-location (concat org-misc-dir "archive/%s_archive::")
	org-extend-today-until 2)

  :config
  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode))

