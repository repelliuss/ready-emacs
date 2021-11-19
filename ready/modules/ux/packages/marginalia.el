;;; marginalia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :after (selectrum)
  :init
  (marginalia-mode 1)
  :general
  (selectrum-minibuffer-map
   "M-m" #'marginalia-cycle))

;; TODO: check doom's enhancements
