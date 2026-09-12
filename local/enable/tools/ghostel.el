;;; ghostel.el -*- lexical-binding: t; -*-

(cfg-pkg ghostel
  (:bind rps-keymap-open
         "t" #'ghostel)
  (:opt ghostel-initial-input-mode 'line))
