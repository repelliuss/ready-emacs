;;; olivetti.el -*- lexical-binding: t; -*-

(use-package olivetti
  :attach (org-tree-slide)
  (advice-add #'org-tree-slide-mode
	      :after
	      #'olivetti-mode)
  :attach (rps/editor/toggle)
  (bind rps/toggle-map
	"o" #'olivetti-mode)
  :config
  (setq-default olivetti-body-width 74))
