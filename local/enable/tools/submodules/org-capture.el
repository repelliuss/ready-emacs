;;; org-capture.el -*- lexical-binding: t; -*-

(use-package org-capture
  :straight (:type built-in)
  :init
  (bind rps/note-map
	(bind-autoload "org-capture"
	  "c" #'rps-org-capture
	  "g" #'rps-org-capture-visit))

  (defvar /org-gtd-capture-templates
    '(("s" "stuff" (org-capture nil "s"))
      ("p" "project" (org-capture nil "p"))))

  (defvar /org-gtd-capture-goto-templates
    '(("2" "Last 24h" (find-file (concat rps-org-gtd-dir "24h.org")))
      ("d" "Daybook" (find-file (concat rps-org-gtd-dir "daybook.org")))
      ("f" "Future" (find-file (concat rps-org-gtd-dir "future.org")))
      ("p" "Project" (let ((project-name (rps-org-gtd-get-project-name)))
                       (find-file (concat rps-org-gtd-dir "project.org"))
                       (when-let ((project-marker (org-find-exact-headline-in-buffer project-name)))
                         (goto-char project-marker)
                         (org-narrow-to-subtree))))
      ("r" "Reminder" (find-file (concat rps-org-gtd-dir "reminder.org")))
      ("s" "Stuff" (find-file (concat rps-org-gtd-dir "stuff.org")))
      ("t" "Todo" (find-file (concat rps-org-gtd-dir "todo.org")))
      ("l" "Logs")
      ("lg" "Game" (find-file (concat rps-org-gtd-log-dir "game.org")))
      ("lw" "Watch" (find-file (concat rps-org-gtd-log-dir "watch.org")))
      ("lb" "Book" (find-file (concat rps-org-gtd-log-dir "book.org")))
      ("lm" "Music" (find-file (concat rps-org-gtd-log-dir "music.org")))))

  :config
  (setq org-capture-templates `(("s" "stuff" entry
                                 (file ,(concat rps-org-gtd-dir "stuff.org"))
                                 "* STUFF %?")
                                ("p" "project" entry
                                 #'rps--org-gtd-goto-project-or-new-in-stuff
                                 "* STUFF %?")))

  (defun rps-org-capture ()
    (interactive)
    (let* ((default-templates org-capture-templates)
           (org-capture-templates /org-gtd-capture-templates)
           (template (rps--org-capture-select-template))
           (org-capture-templates default-templates))
      (when (consp template)
        (eval (nth 2 template)))))

  (defun rps-org-capture-visit ()
    (interactive)
    (let* ((org-capture-templates /org-gtd-capture-goto-templates)
           (template (rps--org-capture-select-template)))
      (when (consp template)
        (eval (nth 2 template)))))

  (defun rps-org-capture-log (func file prompt)
    (let ((entry (read-string prompt))
          (path (concat rps-org-gtd-log-dir file)))
      (with-current-buffer (find-file-noselect path)
        (goto-char (point-min))
        (funcall func entry)
        (call-interactively #'rps-org-gtd-todo)
        (org-id-get-create)
        (save-buffer))))

  (defun rps-org-gtd-get-project-name ()
    (when-let* ((project (project-current))
		(dir (project-root project)))
      (if (string-match "/\\([^/]+\\)/\\'" dir)
	  (match-string 1 dir)
	dir))
    "")

  (defun rps--org-capture-select-template ()
    (org-mks org-capture-templates
	     "Capture:"
	     ""
	     '(("q" "quit"))))

  (defun rps--org-gtd-complete-project ()
    (let* ((org-refile-targets
            (list (cons (concat rps-org-gtd-dir rps-org-gtd-project-file) (cons :level 1))))
           (org-refile-use-outline-path nil)
           (refile-targets (org-refile-get-targets))
           (completion-ignore-case t)
           (existing-projects (mapcar (lambda (target)
                                        (car target))
                                      refile-targets))
           (current-project (rps-org-gtd-get-project-name)))
      (completing-read "Project name: "
                       (if current-project
                           (add-to-list 'existing-projects current-project)
                         existing-projects))))

  (defun rps--org-gtd-goto-project-or-new-in-stuff (&rest _)
    (let ((project-name (rps--org-gtd-complete-project)))
      (set-buffer (find-file-noselect
                   (concat rps-org-gtd-dir rps-org-gtd-stuff-file)))
      (if-let ((project-marker (org-find-exact-headline-in-buffer project-name)))
          (goto-char project-marker)
        (goto-char (org-find-exact-headline-in-buffer rps-org-gtd-projects-header))
        (forward-line)
        (insert (concat "** " project-name))))))
