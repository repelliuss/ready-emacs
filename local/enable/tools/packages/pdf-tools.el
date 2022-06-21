;;; pdf-tools.el -*- lexical-binding: t; -*-

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :config
  (bind pdf-view-mode-map
	"l" #'image-forward-hscroll
	"h" #'image-backward-hscroll)
  
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-use-scaling t
        pdf-view-use-imagemagick nil)
  (dolist (fn '(pdf-links-minor-mode
		pdf-isearch-minor-mode))
      (add-hook 'pdf-view-mode-hook fn)))

(use-package org-pdftools
  :after pdf-tools
  :hook (org-mode . org-pdftools-setup-link))

