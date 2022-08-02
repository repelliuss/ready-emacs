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

;;; GTD WORKFLOW STARTS HERE

(defvar rps-org-gtd-dir (expand-file-name (concat org-directory "roam/gtd/")))
(defvar rps-org-gtd-log-dir (expand-file-name (concat org-directory "roam/log/")))

(defvar rps-org-gtd-project-file "project.org")
(defvar rps-org-gtd-stuff-file "stuff.org")

(defvar rps-org-gtd-log-file "24h.org")
(defvar rps-org-gtd-log-last-days 1)
(defvar rps-org-gtd-log-states '("DONE"))

(defvar rps-org-gtd-projects-header "Projects")

(use-package org
  :after org
  :config
  (bind org-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "t" #'rps-org-gtd-todo
	  "q" #'rps-consult-org-select-tags))

  (setq org-todo-keywords
        '((sequence "PROJECT(p)" "|" "DONE(d)")
          (sequence "TODO(t)" "PENDING(p)" "|" "DONE(d)" "DELEGATED(D)" "CANCELED(c)")
          (sequence "REMINDER(r)" "|" "CANCELED(c)")
          (sequence "FUTURE(s)" "|" "CANCELED(c)")
          (sequence "TODO(t)" "|" "DONE(d)" "CANCELED(c)")))
  
  (setq org-tag-alist '((:startgroup)
                        ("@computer" . ?c)
                        ("@home" . ?h)
                        ("@phone" . ?p)
                        ("@errand" . ?e)
                        (:endgroup)
                        (:startgroup)
                        ("read" . ?r)
                        (:endgroup)
                        (:startgroup)
                        ("airties" . ?a)
                        (:endgroup)))

  (setq org-columns-default-format "%50ITEM(Task) %CLOCKSUM_T(Day){:} %CLOCKSUM(All){:} %Effort(Est){:} %COMPLETE(Completion Date)")

  (add-to-list 'org-global-properties '("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00"))

  (add-hook 'org-after-refile-insert-hook #'org-update-parent-todo-statistics))
