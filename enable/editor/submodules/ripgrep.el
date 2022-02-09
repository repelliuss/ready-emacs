;;; ripgrep.el -*- lexical-binding: t; -*-

(use-package consult
  :straight nil
  :after (rps/editor/search)
  :init
  (bind rps/search-map
	"g" #'consult-ripgrep))

;; TODO: add checks for ripgrep and fd executables
