;;; marginalia.el -*- lexical-binding: t; -*-

(cfg-pkg marginalia
  (marginalia-mode 1)

  (:after vertico
    (:bind vertico-map "M-m" #'marginalia-cycle)))

