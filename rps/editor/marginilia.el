;;; marginilia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :demand
  :after (selectrum)
  :bind (:map selectrum-minibuffer-map
         ("M-m" . marginalia-cycle))
  :config
  (marginalia-mode 1))
