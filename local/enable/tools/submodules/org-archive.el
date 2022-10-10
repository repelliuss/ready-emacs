;;; org-archive.el -*- lexical-binding: t; -*-

(use-package org-archive
  :straight (:type built-in)
  :config
  (setq org-archive-save-context-info
	(delq 'time org-archive-save-context-info)))
