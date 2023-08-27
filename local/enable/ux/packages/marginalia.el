;;; marginalia.el -*- lexical-binding: t; -*-

(setup marginalia
  (marginalia-mode 1)
	
  (:with-feature vertico
    (:when-loaded
      (:bind vertico-map
	     "M-m" #'marginalia-cycle))))

;; TODO: check doom's enhancements
