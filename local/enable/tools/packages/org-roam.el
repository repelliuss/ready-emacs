;;; org-roam.el -*- lexical-binding: t; -*-

;;; See org-protocol note.

(use-package org-roam
  :init
  (setq org-roam-directory (concat org-directory "note/")
	org-roam-db-location (concat ~dir-cache "org-roam.db")
	org-roam-dailies-directory "journal/")

  (require 'org-roam-protocol)

  (setq org-roam-capture-ref-templates `(("r" "ref" plain "%?" :target
					  (file+head "${slug}.org" ,(concat "#+title: ${title}\n"
									    "#+category: note\n"
									    "#+date: %<%FT%T%z>"))
					  :unnarrowed t)))

  (advice-add #'org-protocol-capture :around (defun /org-protocol-capture-bind-capture-protocols (fn &rest rest)
					       (let ((org-capture-templates '(("s" "protocol stuff" entry
									       (file "c:/Users/repelliuss/home/org/gtd/stuff.org")
									       "* STUFF %? %a\n%i"))))
						 (apply fn rest))))

  (advice-add #'org-protocol-store-link :after #'delete-frame)
  (advice-add #'org-protocol-capture :before #'/org-protocol-capture-prepare)
  (advice-add #'org-roam-protocol-open-ref :before #'/org-protocol-capture-prepare)

  (defun /org-protocol-capture-prepare (&rest _)
    (add-hook 'org-capture-mode-hook #'delete-other-windows)
    (add-hook 'org-capture-after-finalize-hook #'delete-frame)
    (add-hook 'org-capture-after-finalize-hook #'/org-protocol-capture-remove 50))

  (defun /org-protocol-capture-remove (&rest _)
    (remove-hook 'org-capture-after-finalize-hook #'/org-protocol-capture-remove)
    (remove-hook 'org-capture-mode-hook #'delete-other-windows)
    (remove-hook 'org-capture-after-finalize-hook #'delete-frame))

  :config
  (add-to-list 'org-roam-mode-sections #'org-roam-unlinked-references-section)
  
  (make-directory (concat org-roam-directory org-roam-dailies-directory) 'with-parents)

  (org-roam-db-autosync-mode 1))

