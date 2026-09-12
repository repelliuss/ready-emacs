;;; vundo.el -*- lexical-binding: t; -*-

(cfg-pkg vundo
  (:opt vundo-glyph-alist vundo-unicode-symbols
        vundo-window-max-height 4)
  (:after meow
    (:bind rps-keymap-normal
           "M-u" #'vundo)))
