;;; org-remark.el -*- lexical-binding: t; -*-

(use-package org-remark
  :attach (org)
  (require 'org-remark-global-tracking)
  (org-remark-global-tracking-mode 1)

  ;; REVIEW: is org-remark still noisy at upstream

  :init
  (setq org-remark-notes-file-path (concat org-misc-dir "org-remark.org"))

  :config
  (bind
   ((setq org-remark-map (make-sparse-keymap))
    "a" #'org-remark-mark
    "o" #'org-remark-open
    "[" #'org-remark-prev
    "]" #'org-remark-next
    "{" #'org-remark-view-prev
    "}" #'org-remark-view-next
    "d" #'org-remark-remove
    "k" #'org-remark-delete
    "s" #'org-remark-save
    "c" #'org-remark-change
    "t" #'org-remark-toggle
    "v" #'org-remark-view)
   (org-mode-map
    "C-c a" org-remark-map)))
