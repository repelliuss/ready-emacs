;;; org.el -*- lexical-binding: t; -*-

(use-package org
  :init
  (defvar rps-org-gtd-dir (expand-file-name (concat org-directory "roam/gtd/")))
  (defvar rps-org-gtd-log-dir (expand-file-name (concat org-directory "roam/log/")))

  (defvar rps-org-gtd-project-file "project.org")
  (defvar rps-org-gtd-stuff-file "stuff.org")

  (defvar rps-org-gtd-log-file "24h.org")
  (defvar rps-org-gtd-log-last-days 1)
  (defvar rps-org-gtd-log-states '("DONE"))

  (defvar rps-org-gtd-projects-header "Projects")

  :config
  (bind org-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "t" #'rps-org-gtd-todo
	  "q" #'rps-consult-org-select-tags))

  (setq org-ellipsis "…")

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

  (setq org-archive-location (concat org-misc-dir "archive/%s_archive::"))

  (setq org-extend-today-until 2)

  (add-to-list 'org-global-properties '("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00"))

  (add-hook 'org-after-refile-insert-hook #'org-update-parent-todo-statistics))

(use-package org-capture
  :straight (:type built-in)
  :init
  (bind rps/note-map
	(bind-command "org-capture"
	  "c" #'rps-org-capture
	  "g" #'rps-org-capture-visit))

  (defvar rps-org-capture-templates
    '(("s" "stuff" (org-capture nil "s"))
      ("p" "project" (org-capture nil "p"))))

  (defvar rps-org-capture-goto-templates
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
           (org-capture-templates rps-org-capture-templates)
           (template (rps--org-capture-select-template))
           (org-capture-templates default-templates))
      (when (consp template)
        (eval (nth 2 template)))))

  (defun rps-org-capture-visit ()
    (interactive)
    (let* ((org-capture-templates rps-org-capture-goto-templates)
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


(use-package org-refile
  :straight (:type built-in)
  :config
  (setq org-refile-targets '((org-agenda-files :level . 0))
        org-refile-use-outline-path 'file)

  (defun rps-org-gtd-todo (&optional arg)
    (interactive "P")
    (org-todo arg)
    (if (string-prefix-p rps-org-gtd-log-dir default-directory)
	(progn (rps--org-gtd-copy-to-log 'log-entry) (save-buffer))
      (when (string-prefix-p rps-org-gtd-dir default-directory)
	(rps-org-gtd-process)
	(when org-capture-mode
          (org-capture-kill)))))

  (defun rps-org-gtd-process ()
    (interactive)
    (let ((done-p (org-entry-is-done-p))
          (in-project-p (string= "project.org" (buffer-name)))
          (top-level-p (= 1 (org-current-level))))
      (rps--org-gtd-copy-to-log)
      (if (and (not top-level-p) done-p in-project-p)
          (rps-org-move-heading-to-bottom-then-next))
      (when top-level-p
        (if done-p
            (org-archive-subtree-default)
          (rps-org-gtd-refile)))
      (save-buffer)))

  (defun rps-org-gtd-refile (&rest args)
    (interactive "P")
    (org-entry-put nil "PROCESS" (rps--org-inactive-time-stamp-now))
    (org-id-get-create)
    (if (not (= 3 (org-current-level))) ; if not a project stuff
        (pcase (org-get-todo-state)
          ("STUFF"
           (apply #'org-refile args))
          ("PROJECT"
           (rps--org-gtd-refile-to-project))
          ((and state
                (or "TODO"
                    "REMINDER"
                    "FUTURE"))
           (org-refile nil nil (let ((file (concat (downcase state) ".org")))
                                 (list file (concat rps-org-gtd-dir file)
                                       nil nil))))
          (_ (apply #'org-refile args)))
      (rps--org-gtd-refile-to-known-project)))

  (defun rps-org-move-heading-to-bottom-then-next ()
    (interactive)
    (when-let (((org-get-next-sibling))
               ((org-get-last-sibling))
               ((org-move-subtree-down))
               (next-heading (org-get-last-sibling))
               ((org-get-next-sibling)))
      (while (org-get-next-sibling)
	(org-get-last-sibling)
	(org-move-subtree-down))
      (goto-char next-heading)))

  (defun rps--org-gtd-make-project-rfloc (project-name)
    (let ((refile-file (concat rps-org-gtd-dir rps-org-gtd-project-file))
          refile-pos)
      (with-current-buffer (find-file-noselect refile-file)
        (setq refile-pos (org-find-exact-headline-in-buffer project-name))
        (unless refile-pos
          (goto-char (point-max))
          (insert (concat "* PROJECT " project-name " [/]"))
          (org-entry-put nil "COOKIE_DATA" "todo recursive")
          (setq refile-pos (point))))
      (list project-name refile-file nil refile-pos)))

  (defun rps--org-gtd-refile-to-known-project ()
    (let (rfloc up-heading-point)
      (save-excursion
        (org-up-heading-safe)
        (setq up-heading-point (point)
              rfloc (rps--org-gtd-make-project-rfloc (org-entry-get nil "ITEM"))))
      (org-todo "TODO")
      (let ((org-reverse-note-order t))
        (org-refile nil nil rfloc))
      (save-excursion
        (goto-char up-heading-point)
        (if (not (outline-has-subheading-p))
            (org-cut-subtree)))))

  (defun rps--org-gtd-refile-to-project ()
    (org-todo "TODO")
    (let ((org-reverse-note-order t))
      (org-refile nil nil
                  (rps--org-gtd-make-project-rfloc
                   (rps--org-gtd-complete-project)))))

  (defun rps--org-gtd-kill-overdue-logs ()
    (interactive)
    (with-current-buffer (find-file-noselect (concat rps-org-gtd-dir
                                                     rps-org-gtd-log-file))
      (goto-char (point-min))
      (let ((continue t)
            (now (current-time)))
        (while (and (re-search-forward ":COMPLETE: *\\[\\([^]]+\\)\\]" nil t 1)
                    continue)
          (if (<= (time-to-number-of-days
                   (time-subtract now
                                  (apply #'encode-time
                                         (org-parse-time-string (match-string 1)))))
                  rps-org-gtd-log-last-days)
              (setq continue nil)
            (org-cut-subtree))))
      (save-buffer)))

  (defun rps--org-gtd-copy-to-log (&optional log-entry-p)
    (when (or log-entry-p
	      (member (org-get-todo-state) rps-org-gtd-log-states))
      (org-entry-put nil "COMPLETE" (rps--org-inactive-time-stamp-now))
      (rps--org-gtd-kill-overdue-logs)
      (let ((org-refile-keep t))
        (org-refile nil nil (list rps-org-gtd-log-file
                                  (concat rps-org-gtd-dir rps-org-gtd-log-file)
                                  nil nil)))))

  (defun rps--org-inactive-time-stamp-now ()
    (concat "["
            (format-time-string
             (substring (cdr org-time-stamp-formats) 1 -1))
            "]")))

(use-package org-archive
  :straight (:type built-in)
  :config
  (setq org-archive-save-context-info
	(delq 'time org-archive-save-context-info)))

(use-package org-clock
  :straight (:type built-in)
  :config
  (setq org-clock-idle-time 10))

(use-package org-agenda
  :straight (:type built-in)
  :init
  (bind
   (rps/note-map
    (bind-command "org-agenda"
      "v" #'rps-org-gtd-views)))

  (defvar rps-view-cases
    '(("Agenda" (org-agenda nil "a"))
      ("Daily" (org-agenda nil "d"))))

  :config
  (setq org-agenda-deadline-leaders '(" ⏰ " " ⚠  ⏰ %2dx " " ⚠  ⏰ %2dx ")
        org-agenda-scheduled-leaders '("" " ⚠ %2dx ")
        org-agenda-todo-keyword-format "")

  (setq org-agenda-time-grid '((daily today require-timed)
                               nil
                               "" "..."))

  (setq org-agenda-current-time-string "⠀➤➤➤")

  (setq org-agenda-skip-deadline-if-done t)

  (setq org-agenda-use-time-grid nil)

  (setq org-agenda-start-day nil)

  (setq org-agenda-prefix-format
        '((agenda . " %-8t %4e%s")
          (todo . " %-8t %4e%s")
          (tags . " %i %t %-12:c")
          (search . " %i %t %-12:c")))

  (setq org-agenda-files (mapcar (lambda (file) (concat rps-org-gtd-dir file))
                                 (list rps-org-gtd-project-file
                                       rps-org-gtd-log-file
                                       "todo.org"
                                       "daybook.org"
                                       "reminder.org"
                                       "future.org")))

  (setq org-agenda-custom-commands
        `(("d" "Daily"
           ((agenda "" ((org-agenda-span 'day)
                        (org-agenda-start-day nil)
                        (org-agenda-overriding-header "")
                        (org-deadline-warning-days 0)
                        (org-super-agenda-groups
                         '((:discard (:todo ("DONE" "CANCELED")))
                           (:name "Anytime" :pred rps--org-gtd-no-time-p)))
                        (org-super-agenda-unmatched-name "At time")
                        (org-super-agenda-unmatched-order -1)
                        (org-agenda-use-time-grid t)
                        (org-agenda-prefix-format '((agenda . " %-8t%4e%s")))
                        (org-agenda-format-date (lambda (_) ""))))
            (todo "DONE"
                  ((org-agenda-overriding-header "")
                   (org-agenda-prefix-format '((todo . " %-9i ✅")))
                   (org-super-agenda-groups (if (rps--org-gtd-log-has-item-p)
                                                '((:discard (:file-path "project.org"))
                                                  (:name "Last 24h" :todo "TODO"))
                                              '((:discard (:anything))))))))
           ((org-agenda-block-separator nil)))))

  (setq org-agenda-clockreport-parameter-plist
	(plist-put org-agenda-clockreport-parameter-plist
		   :emphasize t))

  (advice-add #'org-agenda-todo :after
	      (defun rps-org-gtd-agenda-todo (&rest _)
		(save-window-excursion
		  (org-agenda-switch-to)
		  (rps-org-gtd-process))
		(org-agenda-redo)))

  (defun rps-org-gtd-views (view)
    (interactive
     (list
      (completing-read "View: " (mapcar #'car rps-view-cases)
                       nil t nil nil "Daily")))
    (eval `(pcase ,view
             ,@rps-view-cases)))

  (defun rps-org-export-agenda ()
    (interactive)
    (let ((theme doom-theme)
          (file-path (concat org-directory "agenda.html"))
          (agenda-buffer (get-buffer "agenda.html")))
      (rps--org-gtd-kill-overdue-logs)
      (org-agenda nil "d")
      (org-agenda-write file-path)
      (kill-buffer)
      (set-buffer (find-file-noselect file-path))
      (goto-char (point-min))
      (search-forward "body {" nil)
      (insert "\n        font-size: 75%;")
      (save-buffer)
      (unless agenda-buffer
        (kill-buffer "agenda.html"))))

  (run-with-idle-timer (* 60 15) t #'rps-org-export-agenda)

  (defun rps--org-gtd-no-time-p (item)
    (not (string-match " [^ ][0-9]?[0-9]:[0-9][0-9]" item)))

  (defun rps--org-gtd-log-has-item-p ()
    (with-current-buffer (find-file-noselect (concat rps-org-gtd-dir
                                                     rps-org-gtd-log-file))
      (goto-char (point-min))
      (org-forward-heading-same-level 1))))

