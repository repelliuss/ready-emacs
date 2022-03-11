;;; hide-mode-line.el -*- lexical-binding: t; -*-

(use-package hide-mode-line
  :attach (org-tree-slide)
  (advice-add #'org-tree-slide-mode
	      :after
	      #'hide-mode-line-mode))
