;;; text-scale.el -*- lexical-binding: t; -*-

(cfg emacs
  (:bind rps-keymap-toggle
	     "f" #'text-scale-adjust
	     "F" #'global-text-scale-adjust))
