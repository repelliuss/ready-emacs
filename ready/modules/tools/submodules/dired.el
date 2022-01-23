;;; dired.el ---  -*- lexical-binding: t; -*-

(setq dired-listing-switches "-ahl -v --group-directories-first")

(use-package dired
  :straight (:type built-in)
  :extend (meow)
  (general-def dired-mode-map
    "J" #'dired-down-directory
    "K" #'dired-find-file))

(provide 'ready/tools/dired)
