;;; org-gtd.el -*- lexical-binding: t; -*-

;; TODO: where is rps-consult-org-select-tags

(use-package org-gtd
  :straight nil
  :attach (org)
  (bind org-mode-map
	(bind-local
	    "T" #'/org-gtd-select-multiple-tags
	    "g e" #'/org-gtd-export-agenda
	    "g k" #'/org-gtd-kill-overdue-logs
	    "g z" #'/org-gtd-bury-heading)
	[remap org-todo] #'/org-gtd-todo) ; bound to "t"

  :init
  (bind rps/note-map
	"c" #'/org-gtd-capture
	"g" #'/org-gtd-capture-visit
	"v" #'/org-gtd-views))
