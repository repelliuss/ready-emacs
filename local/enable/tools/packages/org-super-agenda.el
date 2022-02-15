;;; org-super-agenda.el -*- lexical-binding: t; -*-

(use-package org-super-agenda
  :config
  (bind org-super-agenda-header-map
	"<tab>" #'+org-super-agenda-header-dwim)

  (setq org-super-agenda-unmatched-name "General"
        org-super-agenda-groups `((:name "Anniversaries" :file-path ,(concat rps-org-gtd-dir
                                                                             "daybook.org"))
                                  (:name "Completed" :todo "DONE")
                                  (:name "Reminders" :todo "REMINDER")
                                  (:auto-parent t))
        org-super-agenda-header-map (make-sparse-keymap)))
