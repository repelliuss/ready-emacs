;;; orgmdb.el -*- lexical-binding: t; -*-

(use-package org-roam
  :attach (org-capture)
  (setq org-roam-db-location (concat cache-dir "org-roam.db"))
  
  (setq rps-org-capture-templates
	(append rps-org-capture-templates '(("n" "note" (org-roam-capture nil "n"))
                                            ("j" "Journal")
                                            ("jd" "Date" (org-roam-dailies-capture-date))
                                            ("jt" "Today" (org-roam-dailies-capture-today))
                                            ("jy" "Yesterday" (org-roam-dailies-capture-yesterday 1))
                                            ("jm" "Tomorrow" (org-roam-dailies-capture-tomorrow 1)))))
  
  (setq rps-org-capture-goto-templates
	(append rps-org-capture-goto-templates '(("n" "Note" (org-roam-capture '(4) "n"))
						 ("j" "Journal")
						 ("jd" "Date" (org-roam-dailies-goto-date))
						 ("jt" "Today" (org-roam-dailies-goto-today))
						 ("jy" "Yesterday" (org-roam-dailies-goto-yesterday 1))
						 ("jm" "Tomorrow" (org-roam-dailies-goto-tomorrow 1)))))
  
  :init
  (setq org-roam-directory (concat org-directory "roam/"))
  (setq org-roam-dailies-directory "journal/")

  :config
  (setq org-roam-file-exclude-regexp rps-org-gtd-log-file
        org-roam-capture-templates `(("n" "note" plain ,(concat "* %?\n"
                                                                ":PROPERTIES:\n"
                                                                ":CREATE: %U\n"
                                                                ":END:")
                                      :if-new (file+head "note/${slug}.org"
                                                         ,(concat "#+title: ${title}\n"
                                                                  "#+category: note\n"
                                                                  "#+date: %<%FT%T%z>"))
                                      :unnarrowed t
                                      :empty-lines 1))))

