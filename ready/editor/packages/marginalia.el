;;; marginalia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :init
  (after! selectrum
    (bind-keys :map selectrum-minibuffer-map
               ("M-m" . marginalia-cycle))
    (marginalia-mode)))
