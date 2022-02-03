;;; org.el -*- lexical-binding: t; -*-

(use-package org
  :init
  (setq org-directory "~/workspace/org/"
	org-misc-dir (concat org-directory "misc/"))
  :config
  (add-hook 'org-mode-hook #'org-indent-mode))

(defvar org-remark-map (make-sparse-keymap))

(use-package org-remark
  :general
  (org-remark-map
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
   "C-c a" org-remark-map)
  
  :attach (org)
  (require 'org-remark-global-tracking)
  (org-remark-global-tracking-mode 1)

  :init
  (setq org-remark-notes-file-path (concat org-misc-dir "org-remark.org")))

