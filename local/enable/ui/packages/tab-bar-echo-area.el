;;; tab-bar-echo-area.el -*- lexical-binding: t; -*-

(use-package tab-bar-echo-area
  :init
  (advice-add #'tab-bar-mode
	      :override
	      #'tab-bar-echo-area-mode))


