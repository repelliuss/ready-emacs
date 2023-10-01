;;; marginalia.el -*- lexical-binding: t; -*-

(setup marginalia
  (marginalia-mode 1)
	
  (:after-feature vertico
    (:bind vertico-map "M-m" #'marginalia-cycle)))

;; TODO: check doom's enhancements
