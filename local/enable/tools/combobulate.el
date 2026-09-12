;;; combobulate.el -*- lexical-binding: t; -*-

(cfg-pkg (:elpaca combobulate
                  :host github
                  :repo "mickeynp/combobulate")
  (:bind rps-keymap-edit
         "c" #'combobulate)
  (:hook-into prog-mode))
