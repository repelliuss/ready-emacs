;;; marginalia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :attach (selectrum)
  (bind selectrum-minibuffer-map
	"M-m" #'marginalia-cycle)
  
  :attach (vertico)
  (bind vertico-map
	"M-m" #'marginalia-cycle)
  
  :init
  (marginalia-mode 1))

;; TODO: check doom's enhancements
