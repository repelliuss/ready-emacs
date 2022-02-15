;;; puni.el -*- lexical-binding: t; -*-

(use-package puni
  :attach rps/editor/edit
  (bind rps/edit-map
	"s" #'puni-split
	"]" #'puni-slurp-forward
	"[" #'puni-slurp-backward
	"{" #'puni-barf-backward
	"}" #'puni-barf-forward
	"r" #'puni-raise
	"c" #'puni-convolute
	"t" #'puni-transpose
	"u" #'puni-splice)
  :extend (meow)
  (add-to-list 'meow-selection-command-fallback '(meow-kill . puni-kill-line)))
