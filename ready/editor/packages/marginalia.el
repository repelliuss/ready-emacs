;;; marginalia.el -*- lexical-binding: t; -*-

(use-package marginalia
  :init
  (after! 'selectrum
    (general-def
      :keymaps 'selectrum-minibuffer-map
      "M-m" #'marginalia-cycle)
    (marginalia-mode)))
