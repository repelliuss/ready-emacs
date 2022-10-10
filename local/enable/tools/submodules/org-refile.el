;;; org-refile.el -*- lexical-binding: t; -*-

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

