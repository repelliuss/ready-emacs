;;; dired.el ---  -*- lexical-binding: t; -*-

(setq dired-listing-switches "-ahl -v --group-directories-first")

(use-package dired
  :straight (:type built-in)
  :config
  (setq dired-dwim-target t)
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  :extend (meow)
  (bind dired-mode-map
	"J" #'dired-down-directory
	"K" #'dired-find-file))
