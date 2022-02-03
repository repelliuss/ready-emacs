;;; marginalia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :after (:any selectrum vertico)
  :init
  (marginalia-mode 1)
  :general
  (selectrum-minibuffer-map
    "M-m" #'marginalia-cycle)
  (vertico-map
   "M-m" #'marginalia-cycle))

;; TODO: check doom's enhancements
