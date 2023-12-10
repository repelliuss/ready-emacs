;;; olivetti.el -*- lexical-binding: t; -*-

(setup olivetti
  (:hook-into org-tree-slide)
  (:set olivetti-body-width 74)
  (:bind ~keymap-toggle
         "o" #'olivetti-mode))
