;;; presentation.el -*- lexical-binding: t; -*-

(use-package presentation
  :attach (rps/editor/toggle)
  (bind rps/toggle-map
	"f" #'text-scale-mode
	"F" #'global-text-scale-mode)
  :init
  (defalias 'global-text-scale-mode #'presentation-mode)
  (setq presentation-default-text-scale 3)
  (setq-default text-scale-mode-amount 3))
