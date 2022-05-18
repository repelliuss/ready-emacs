;;; org-agenda.el -*- lexical-binding: t; -*-

(use-package org-agenda
  :straight (:type built-in)
  :init
  (bind
   (rps/note-map
    (bind-autoload "org-agenda"
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
                               "" "…"))

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
