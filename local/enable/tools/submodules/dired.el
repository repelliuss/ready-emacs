;;; dired.el ---  -*- lexical-binding: t; -*-

(use-package dired
  :straight (:type built-in)
  :config
  (setq dired-dwim-target t
	dired-auto-revert-buffer t
	dired-hide-details-hide-symlink-targets nil
	dired-recursive-copies 'always
	dired-recursive-deletes 'top
	dired-create-destination-dirs 'ask
	dired-listing-switches "-ahl -v --group-directories-first") ;; REVIEW: for windows
  
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  :extend (meow)
  (bind dired-mode-map
	"J" #'dired-down-directory
	"K" #'dired-find-file))
