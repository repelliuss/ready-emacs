;;; olivetti.el -*- lexical-binding: t; -*-

(cfg-pkg olivetti
  (:bind rps-keymap-toggle
         "o" #'olivetti-mode)
  (:opt olivetti-body-width 200)
  (:hook-into dired-mode))
