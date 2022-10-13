;;; org-gtd.el -*- lexical-binding: t; -*-

;; TODO: special files should be created with special todo keywords
;; TODO: views need to be fixed
;; TODO: shouldn't be loaded at startup

(require 'org-capture)
(require 'orgmdb)
(require 'org-gamedb)
(require 'org-roam)
(require 'org-super-agenda)
(require 'org-ql)

(defvar /org-gtd-dir (expand-file-name (concat org-directory "gtd/")))

(defvar /org-gtd-project-file '("project.org"
				"#+startup: showall hideblocks
#+todo: TODO(t) PROJECT(p) FUTURE(f) REMINDER(r) | DONE(d) CANCELED(c)

#+begin: columnview :id global :indent t :skip-empty-rows t
#+end:

#+begin: clocktable :scope file-with-archives :tstart \"<-1m>\"
#+end:"))

(defvar /org-gtd-stuff-file '("stuff.org"
			      "#+startup: content
#+todo: STUFF(_) | CANCELED(c)
#+todo: TODO(t) PROJECT(p) FUTURE(f) REMINDER(r)"))

(defvar /org-gtd-log-file '("24h.org"))

(defvar /org-gtd-daybook-file '("daybook.org"
				"#+startup: showall"))

(defvar /org-gtd-todo-file '("todo.org"
			     "#+startup: showall hideblocks
#+todo: TODO(t) PROJECT(p) FUTURE(f) REMINDER(r) | DONE(d) CANCELED(c)

#+begin: clocktable :scope file-with-archives :tstart \"<-1m>\"
#+end:"))

(defvar /org-gtd-future-file '("future.org"
			       "#+todo: TODO(t) PROJECT(p) FUTURE(f) REMINDER(r) | DONE(d) CANCELED(c)"))

(defvar /org-gtd-reminder-file '("reminder.org"
				 "#+todo: TODO(t) PROJECT(p) FUTURE(f) REMINDER(r) | DONE(d) CANCELED(c)"))

(defvar /org-gtd-other-files nil)

(defvar /org-gtd-log-last-days 1)

(defvar /org-gtd-log-states '("DONE"))

(defvar /org-gtd-projects-header "Projects")

(defvar /org-gtd--last-selected-project nil)

(defun /org-gtd--special-files ()
  (list /org-gtd-project-file
	/org-gtd-stuff-file
	/org-gtd-log-file
	/org-gtd-daybook-file
	/org-gtd-todo-file
	/org-gtd-future-file
	/org-gtd-reminder-file))

(defun /org-gtd--special-files-name ()
  (mapcar #'car (/org-gtd--special-files)))

(defun /org-gtd--special-files-path ()
  (mapcar (lambda (file) (concat /org-gtd-dir (car file)))
	  (/org-gtd--special-files)))

;;;
;;; Capture
;;;

(defvar /org-gtd-capture-templates
  '(("s" "stuff" (org-capture nil "s"))
    ("p" "project" (org-capture nil "p"))
    ("n" "note" (org-roam-capture nil "n"))
    ("j" "Journal")
    ("jd" "Date" (org-roam-dailies-capture-date))
    ("jt" "Today" (org-roam-dailies-capture-today))
    ("jy" "Yesterday" (org-roam-dailies-capture-yesterday 1))
    ("jm" "Tomorrow" (org-roam-dailies-capture-tomorrow 1))
    ("l" "Log")
    ("lg" "Game" (/org-gtd-capture-log #'/org-gtd--capture-game "game.org" "Game: "))
    ("lv" "Video" (/org-gtd-capture-log #'/org-gtd--capture-watch "video.org" "Title: "))))

(defvar /org-gtd-capture-goto-templates
  '(("2" "Last 24h" (find-file (concat /org-gtd-dir (car /org-gtd-log-file))))
    ("d" "Daybook" (find-file (concat /org-gtd-dir (car /org-gtd-daybook-file))))
    ("f" "Future" (find-file (concat /org-gtd-dir (car /org-gtd-future-file))))
    ("p" "Project" (let ((project-name (/org-gtd-get-project-name)))
                     (find-file (concat /org-gtd-dir (car /org-gtd-project-file)))
                     (when-let ((project-marker (org-find-exact-headline-in-buffer project-name)))
                       (goto-char project-marker)
                       (org-narrow-to-subtree))))
    ("r" "Reminder" (find-file (concat /org-gtd-dir (car /org-gtd-reminder-file))))
    ("s" "Stuff" (find-file (concat /org-gtd-dir (car /org-gtd-stuff-file))))
    ("t" "Todo" (find-file (concat /org-gtd-dir (car /org-gtd-todo-file))))
    ("l" "Logs")
    ("lg" "Game" (find-file (concat /org-gtd-dir "game.org")))
    ("lv" "Video" (find-file (concat /org-gtd-dir "video.org")))
    ("lb" "Book" (find-file (concat /org-gtd-dir "book.org")))
    ("lm" "Music" (find-file (concat /org-gtd-dir "music.org")))
    ("n" "Note" (org-roam-capture '(4) "n"))
    ("j" "Journal")
    ("jd" "Date" (org-roam-dailies-goto-date))
    ("jt" "Today" (org-roam-dailies-goto-today))
    ("jy" "Yesterday" (org-roam-dailies-goto-yesterday 1))
    ("jm" "Tomorrow" (org-roam-dailies-goto-tomorrow 1))))

(setq org-capture-templates `(("s" "stuff" entry
                               (file ,(concat /org-gtd-dir (car /org-gtd-stuff-file)))
                               "* STUFF %?")
                              ("p" "project" entry
                               #'/org-gtd--goto-project-or-new-in-stuff
                               "* STUFF %?")))

(setq org-roam-capture-templates `(("n" "note" plain "%?"
                                    :if-new (file+head "note/${slug}.org"
                                                       ,(concat "#+title: ${title}\n"
                                                                "#+category: note\n"
                                                                "#+date: %<%FT%T%z>"))
                                    :unnarrowed t
                                    :empty-lines 1)))

;;;
;;; Agenda
;;;

(defvar /org-gtd-views
    '(("Agenda" (org-agenda nil "a"))
      ("Daily" (org-agenda nil "d"))
      ("Tasks" (org-ql-view "Tasks"))
      ("Stuck Projects" (org-ql-view "Stuck Projects"))
      ("Overview Daily" (org-ql-view "Overview Daily"))
      ("Overview Weekly" (org-ql-view "Overview Weekly"))
      ("Logs" (org-ql-view "Logs"))
      ("Education" (org-ql-view "Education"))))

(setq org-agenda-custom-commands
      `(("d" "Daily"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-start-day nil)
                      (org-agenda-overriding-header "")
                      (org-deadline-warning-days 0)
                      (org-super-agenda-groups
                       '((:discard (:todo ("DONE" "CANCELED")))
                         (:name "Anytime" :pred /org-gtd--no-time-p)))
                      (org-super-agenda-unmatched-name "At time")
                      (org-super-agenda-unmatched-order -1)
                      (org-agenda-use-time-grid t)
                      (org-agenda-prefix-format '((agenda . " %-8t%4e%s")))
                      (org-agenda-format-date (lambda (_) ""))))
          (todo "DONE"
                ((org-agenda-overriding-header "")
                 (org-agenda-prefix-format '((todo . " %-9i ✅")))
                 (org-super-agenda-groups (if (/org-gtd--log-has-item-p)
                                              '((:discard (:file-path (car /org-gtd-project-file)))
                                                (:name "Last 24h" :todo "TODO"))
                                            '((:discard (:anything))))))))
         ((org-agenda-block-separator nil)))))

(setq org-ql-views '(("Tasks"
                      :buffers-files org-agenda-files
                      :query (and (todo "TODO") (not (property "MINOR")))
                      :sort (date)
                      :super-groups ((:auto-parent t)))
                     ("Stuck Projects"
                      :buffers-files (lambda () (list (concat /org-gtd-dir (car /org-gtd-project-file))))
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
		      :buffers-files (lambda ()
				       (let ((special-files (/org-gtd--special-files-path)))
					 (seq-remove (lambda (file) (member file special-files))
						     (directory-files /org-gtd-dir
								      'absolute
								      directory-files-no-dot-files-regexp
								      'nosort))))
                      :query (or (todo) (done))
                      :sort (todo)
                      :super-groups ((:auto-tags t)))
                     ("Education"
                      :buffers-files org-agenda-files
                      :query (and (todo) (tags "edu"))
                      :sort (date)
                      :super-groups ((:auto-planning)))))

(setq org-todo-keywords '((sequence "STUFF" "|" "DONE(d)")
			  (sequence "PROJECT(p)" "|" "DONE(d)")
			  (sequence "TODO(t)" "PENDING(p)" "|" "DONE(d)" "DELEGATED(D)" "CANCELED(c)")
			  (sequence "REMINDER(r)" "|" "CANCELED(c)")
			  (sequence "FUTURE(s)" "|" "CANCELED(c)")
			  (sequence "TODO(t)" "|" "DONE(d)" "CANCELED(c)")))

(setq org-tag-alist '((:startgroup) ("@computer" . ?c) ("@home" . ?h) ("@phone" . ?p) ("@errand" . ?e) (:endgroup)))

(setq org-columns-default-format "%50ITEM(Task) %CLOCKSUM_T(Day){:} %CLOCKSUM(All){:} %Effort(Est){:} %COMPLETE(Completion Date)")

(with-eval-after-load 'org-archive
  (setq org-archive-save-context-info (delq 'time org-archive-save-context-info)))

(setq org-clock-idle-time 10)

(setq org-agenda-files (/org-gtd--special-files-path))

(setq org-refile-targets '((org-agenda-files :level . 0))
      org-refile-use-outline-path 'file)

(setq org-agenda-deadline-leaders '(" ⏰ " " ⚠  ⏰ %2dx " " ⚠  ⏰ %2dx ")
      org-agenda-scheduled-leaders '("" " ⚠ %2dx ")
      org-agenda-todo-keyword-format ""
      org-agenda-time-grid '((daily today require-timed) nil "" "…")
      org-agenda-current-time-string "⠀➤➤➤"
      org-agenda-skip-deadline-if-done t
      org-agenda-use-time-grid nil
      org-agenda-start-day nil
      org-agenda-prefix-format '((agenda . " %-8t %4e%s") (todo . " %-8t %4e%s") (tags . " %i %t %-12:c") (search . " %i %t %-12:c"))
      org-agenda-clockreport-parameter-plist (plist-put org-agenda-clockreport-parameter-plist :emphasize t))

(setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))
      org-roam-file-exclude-regexp (car /org-gtd-log-file))

(setq org-super-agenda-unmatched-name "General"
      org-super-agenda-groups `((:name "Anniversaries" :file-path ,(concat /org-gtd-dir (car /org-gtd-daybook-file)))
                                (:name "Completed" :todo "DONE")
                                (:name "Reminders" :todo "REMINDER")
                                (:auto-parent t)))

(add-to-list 'org-global-properties '("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00"))
(add-to-list 'display-buffer-alist `("^\\*Org QL View:" display-buffer-same-window))

(add-hook 'org-after-refile-insert-hook #'org-update-parent-todo-statistics)
(add-hook 'org-agenda-mode-hook #'org-super-agenda-mode)

(advice-add #'org-agenda-todo :after #'org-gtd-agenda-todo)

(run-with-idle-timer (* 60 15) t #'/org-gtd-export-agenda)

(make-directory /org-gtd-dir 'with-parents)

(defun /org-gtd--capture-select-template ()
  (org-mks org-capture-templates
	   "Capture:"
	   ""
	   '(("q" "quit"))))

(defun /org-gtd--complete-project ()
  (let* ((org-refile-use-outline-path nil)
	 (org-refile-targets (list (cons (concat /org-gtd-dir (car /org-gtd-project-file)) (cons :level 1))))
         (existing-projects (mapcar (lambda (target)
				      (replace-regexp-in-string "[[:space:]]*\\[.*\\]$" "" (car target)))
                                    (org-refile-get-targets)))
         (completion-ignore-case t)
         (current-project (/org-gtd-get-project-name)))
    (setq existing-projects (seq-union existing-projects
				       (seq-filter #'identity
						   (list /org-gtd--last-selected-project
							 current-project))))
    (when-let ((selected (completing-read "Project name: " existing-projects)))
      (setq /org-gtd--last-selected-project selected))))

(defun /org-gtd--goto-project-or-new-in-stuff (&rest _)
  (let ((project-name (/org-gtd--complete-project)))
    (set-buffer (find-file-noselect
                 (concat /org-gtd-dir (car /org-gtd-stuff-file))))
    (if-let ((project-marker (org-find-exact-headline-in-buffer project-name)))
        (goto-char project-marker)
      (if-let ((project-marker (org-find-exact-headline-in-buffer /org-gtd-projects-header)))
	  (goto-char project-marker)
	(end-of-buffer)
	(insert (concat "* " /org-gtd-projects-header "\n")))
      (forward-line)
      (insert (concat "** " project-name "\n"))
      (previous-line))))

(defun /org-gtd--no-time-p (item)
  (not (string-match " [^ ][0-9]?[0-9]:[0-9][0-9]" item)))

(defun /org-gtd--log-has-item-p ()
  (with-current-buffer (find-file-noselect (concat /org-gtd-dir
                                                   (car /org-gtd-log-file)))
    (goto-char (point-min))
    (org-forward-heading-same-level 1)))

(defun /org-gtd--make-project-rfloc (project-name)
  (let ((refile-file (concat /org-gtd-dir (car /org-gtd-project-file)))
        refile-pos)
    (with-current-buffer (find-file-noselect refile-file)
      (setq refile-pos (org-find-exact-headline-in-buffer project-name))
      (unless refile-pos
        (goto-char (point-max))
        (insert (concat "* PROJECT " project-name " [/]"))
        (org-entry-put nil "COOKIE_DATA" "todo recursive")
        (setq refile-pos (point))))
    (list project-name refile-file nil refile-pos)))

(defun /org-gtd--refile-to-known-project ()
  (let (rfloc up-heading-point)
    (save-excursion
      (org-up-heading-safe)
      (setq up-heading-point (point)
	    rfloc (/org-gtd--make-project-rfloc (org-entry-get nil "ITEM"))))
    (org-todo "TODO")
    (let ((org-reverse-note-order t))
      (org-refile nil nil rfloc))
    (save-excursion
      (goto-char up-heading-point)
      (message (org-entry-get nil "ITEM"))
      (if (not (org-goto-first-child))
          (org-cut-subtree)))))

(defun /org-gtd--refile-to-project ()
  (org-todo "TODO")
  (let ((org-reverse-note-order t))
    (org-refile nil nil
                (/org-gtd--make-project-rfloc
                 (/org-gtd--complete-project)))))

(defun /org-gtd--copy-to-log (&optional log-entry-p)
  (when (or log-entry-p
	    (member (org-get-todo-state) /org-gtd-log-states))
    (let (org-special-properties)
      (org-entry-put nil "CLOSED" (/org-gtd--inactive-time-stamp-now)))
    (/org-gtd-kill-overdue-logs)
    (let ((org-refile-keep t))
      (org-refile nil nil (list (car /org-gtd-log-file)
                                (concat /org-gtd-dir (car /org-gtd-log-file))
                                nil nil)))))

(defun /org-gtd--inactive-time-stamp-now ()
  (concat "["
          (format-time-string
           (substring (cdr org-time-stamp-formats) 1 -1))
          "]"))

(defun /org-gtd--save-owned-buffers ()
  (save-some-buffers 'non-files-too (lambda () (string-prefix-p (expand-file-name /org-gtd-dir) (buffer-file-name)))))

(defun /org-gtd--capture-game (entry)
  (org-insert-heading)
  (insert (concat " " entry))
  (call-interactively #'org-gamedb-games-query))

(defun /org-gtd--capture-watch (entry)
  (interactive)
  (let* ((category (completing-read "Category: "
                                    '("Movies" "Animes" "Series")
                                    nil t))
         (type (pcase category
                 ("Movies" 'movie)
                 ((or "Animes" "Series") 'series))))
    (goto-char (org-find-exact-headline-in-buffer category))
    (outline-next-heading)
    (save-excursion
      (orgmdb-movie-properties :title entry :type type)
      (goto-char (point-min))
      (org-cut-subtree)
      (kill-buffer))
    (org-paste-subtree)))

(defun /org-gtd-capture-log (func file prompt)
  (let ((entry (read-string prompt))
        (path (concat /org-gtd-dir file)))
    (with-current-buffer (find-file-noselect path)
      (goto-char (point-max))
      (funcall func entry)
      (org-id-get-create)
      (call-interactively #'/org-gtd-todo)
      (save-buffer))))

(defun /org-gtd-get-project-name ()
  (when-let* ((project (project-current))
	      (dir (project-root project)))
    (if (string-match "/\\([^/]+\\)/\\'" dir)
	(match-string 1 dir)
      dir)))

(defun /org-gtd-refile (&rest args)
  (if (= 2 (org-current-level))
      (if (not (org-goto-first-child))
	  (org-cut-subtree)
	(while (org-get-next-sibling)
	  (org-get-previous-sibling)
	  (/org-gtd-todo "TODO"))
	(/org-gtd-todo "TODO"))
    (org-id-get-create)
    (org-entry-put nil "OPEN" (/org-gtd--inactive-time-stamp-now))
    (if (not (= 3 (org-current-level))) ; if not a project stuff
	(pcase (org-get-todo-state)
          ("STUFF" (apply #'org-refile args))
          ("PROJECT" (/org-gtd--refile-to-project))
          ((and state (or "TODO" "REMINDER" "FUTURE"))
           (org-refile nil nil (let ((file (concat (downcase state) ".org")))
				 (list file (concat /org-gtd-dir file)
                                       nil nil))))
          (_ (apply #'org-refile args)))
      (/org-gtd--refile-to-known-project))))

(defun /org-gtd-process-heading ()
  (let ((done-p (org-entry-is-done-p))
        (in-project-p (string= (car /org-gtd-project-file) (buffer-name)))
        (top-level-p (= 1 (org-current-level))))
    (if (and (not top-level-p) done-p in-project-p)
        (/org-gtd-bury-heading)
      (if (not done-p)
          (/org-gtd-refile)
	 (/org-gtd--copy-to-log)
        (org-archive-subtree-default)))))

;;;
;;;
;;; Core
;;;
;;;

;;;
;;; Capture
;;;

;;;###autoload
(defun /org-gtd-capture ()
  (interactive)
  (let* ((default-templates org-capture-templates)
         (org-capture-templates /org-gtd-capture-templates)
         (template (/org-gtd--capture-select-template))
         (org-capture-templates default-templates))
    (when (consp template)
      (eval (nth 2 template)))))

;;;###autoload
(defun /org-gtd-capture-visit ()
  (interactive)
  (let* ((org-capture-templates /org-gtd-capture-goto-templates)
         (template (/org-gtd--capture-select-template)))
    (when (consp template)
      (eval (nth 2 template)))))

;;;
;;; Agenda
;;;

;;;###autoload
(defun /org-gtd-views (view)
  (interactive
   (list (completing-read "View: " (mapcar #'car /org-gtd-views) nil t nil nil "Daily")))
  (eval `(pcase ,view ,@/org-gtd-views)))

;;;
;;; Review
;;;

;;;###autoload
(defun /org-gtd-todo (&optional arg)
  (interactive "P")
  (org-todo arg)
  (when (string-prefix-p /org-gtd-dir default-directory)
    (if (and (buffer-file-name) (not (member (file-name-nondirectory (buffer-file-name)) (/org-gtd--special-files-name))))
	(if (not (org-entry-is-done-p))
	    (org-entry-put nil "OPEN" (/org-gtd--inactive-time-stamp-now))
	  (/org-gtd-bury-heading)
	  (/org-gtd--copy-to-log 'log-entry))
      (if org-capture-mode (widen))
      (/org-gtd-process-heading)
      (if org-capture-mode (org-capture-kill)))
    (/org-gtd--save-owned-buffers)))

;; REVIEW: may not work
;;;###autoload
(defun /org-gtd-agenda-todo (&rest _)
  (interactive)
  (save-window-excursion
    (org-agenda-switch-to)
    (/org-gtd-process-heading))
  (org-agenda-redo)
  (/org-gtd--save-owned-buffers))

;;;
;;;
;;; Helpers
;;;
;;;

;;;
;;; Review
;;;

;;;###autoload
(defun /org-gtd-select-multiple-tags ()
    (interactive)
    (let ((cur-tags (org-get-tags nil 'local))
          (new-tags (completing-read-multiple "Tags: "
					      (mapcar #'car
						      (org-global-tags-completion-table org-agenda-files))
					      nil nil nil 'org-tags-history)))
      (mapc (lambda (elt)
              (setq cur-tags
                    (if (member elt cur-tags)
                        (delete elt cur-tags)
                      (cons elt cur-tags))))
            new-tags)
      (org-set-tags cur-tags)))

;;;###autoload
(defun /org-gtd-bury-heading ()
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

;;;
;;; Maintenance
;;;

;;;###autoload
(defun /org-gtd-export-agenda ()
  (interactive)
  (let ((theme doom-theme)
        (file-path (concat org-directory "agenda.html"))
        (agenda-buffer (get-buffer "agenda.html")))
    (/org-gtd-kill-overdue-logs)
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

;;;###autoload
(defun /org-gtd-kill-overdue-logs ()
  (interactive)
  (with-current-buffer (find-file-noselect (concat /org-gtd-dir (car /org-gtd-log-file)))
    (goto-char (point-min))
    (let ((continue t)
          (now (current-time)))
      (while (and (re-search-forward ":CLOSED: *\\[\\([^]]+\\)\\]" nil t 1)
                  continue)
        (if (<= (time-to-number-of-days
                 (time-subtract now
                                (apply #'encode-time
                                       (org-parse-time-string (match-string 1)))))
                /org-gtd-log-last-days)
            (setq continue nil)
          (org-cut-subtree))))
    (save-buffer)))

(defun /org-gtd-init ()
  (make-directory /org-gtd-dir 'with-parents)
  (dolist (special-file (append (/org-gtd--special-files) /org-gtd-other-files))
    (let* ((file-name (car special-file))
	   (file-path (concat /org-gtd-dir file-name)))
      (when (not (file-exists-p file-path))
	(with-temp-buffer
	  (insert (concat "#+title: " file-name "\n#+category: gtd\n"))
	  (if-let ((props (cadr special-file)))
	      (insert props))
	  (write-file file-path))))))

;; TODO: Remove from here
(add-to-list '/org-gtd-other-files '("game.org"
				     "#+filetags: game
#+todo: PLAY(t) PLAYING(i) | LIKED(d) DISLIKED(b) STOPPED(c)"))

(add-to-list '/org-gtd-other-files '("video.org"
				     "#+filetags: video
#+todo: WATCH(t) WATCHING(i) | LIKED(d) DISLIKED(b) STOPPED(c)"))

(add-to-list '/org-gtd-other-files '("music.org"
				     "#+filetags: music
#+todo: LISTEN(t) | LIKED(d) DISLIKED(c) STOPPED(c)"))

(add-to-list '/org-gtd-other-files '("book.org"
				     "#+filetags: book
#+todo: READ(t) READING(i) | LIKED(d) DISLIKED(c) STOPPED(c)"))

(/org-gtd-init)

(provide 'org-gtd)
