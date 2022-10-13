;;; org-roam.el -*- lexical-binding: t; -*-

(use-package org-roam
  :attach (org-protocol)
  (require 'org-roam-protocol)

  :init
  (setq org-roam-directory (concat org-directory "note/")
	org-roam-db-location (concat cache-dir "org-roam.db")
	org-roam-dailies-directory "journal/")

  :config
  (add-to-list 'org-roam-mode-sections #'org-roam-unlinked-references-section)
  
  (advice-add #'org-roam-protocol-open-ref :before #'/org-roam-protocol-capture-prepare)

  (make-directory org-roam-directory 'with-parents)

  (org-roam-db-autosync-mode 1)

  ;; REVIEW: remove bad handling
  (defun /org-roam-protocol-capture-prepare (&rest _)
    (add-hook 'org-capture-mode-hook #'delete-other-windows)
    (add-hook 'org-capture-after-finalize-hook #'delete-frame)
    (add-hook 'org-capture-after-finalize-hook #'/org-roam-protocol-capture-remove 50))

  (defun /org-roam-protocol-capture-remove (&rest _)
    (remove-hook 'org-capture-after-finalize-hook #'/org-roam-protocol-capture-remove)
    (remove-hook 'org-capture-mode-hook #'delete-other-windows)
    (remove-hook 'org-capture-after-finalize-hook #'delete-frame)))

