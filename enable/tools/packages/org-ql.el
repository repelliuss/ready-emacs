;;; org-ql.el -*- lexical-binding: t; -*-


(use-package org-ql
  :config
  (add-to-list 'display-buffer-alist `("^\\*Org QL View:" display-buffer-same-window))

  (setq org-ql-views `(("Tasks"
                        :buffers-files org-agenda-files
                        :query (and (todo "TODO") (not (property "MINOR")))
                        :sort (date)
                        :super-groups ((:auto-parent t)))
                       ("Stuck Projects"
                        :buffers-files ,(concat rps-org-gtd-directory "project.org")
                        :query (and (todo "PROJECT") (not (children (todo))))
                        :sort (date)
                        :super-groups ((:auto-tags t)))
                       ("Overview Daily"
                        :buffers-files org-agenda-files
                        :query (and (todo) (not (todo "PROJECT" "FUTURE" "REMINDER")) (not (property "MINOR")))
                        :sort (date)
                        :super-groups ((:auto-parent t) (:auto-todo t)))
                       ("Overview Weekly"
                        :buffers-files org-agenda-files
                        :query (and (todo) (not (todo "PROJECT")) (not (property "MINOR")))
                        :sort (date)
                        :super-groups ((:auto-parent t) (:auto-todo t)))
                       ("Logs"
                        :buffers-files ,(rps-get-files-in-directory (concat org-roam-directory
                                                                            "log/")
                                                                    'absolute)
                        :query (or (todo) (done))
                        :sort (todo)
                        :super-groups ((:auto-tags t)))
                       ("Education"
                        :buffers-files org-agenda-files
                        :query (and (todo) (tags "edu"))
                        :sort (date)
                        :super-groups ((:auto-planning)))))

  :extend (org-agenda)
  (setq rps-view-cases
	(append rps-view-cases
		'(("Tasks" (org-ql-view "Tasks"))
		  ("Stuck Projects" (org-ql-view "Stuck Projects"))
		  ("Overview Daily" (org-ql-view "Overview Daily"))
		  ("Overview Weekly" (org-ql-view "Overview Weekly"))
		  ("Logs" (org-ql-view "Logs"))
		  ("Education" (org-ql-view "Education"))))))
