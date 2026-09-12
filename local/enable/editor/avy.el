;;; avy.el -*- lexical-binding: t; -*-

(cfg-pkg avy
  (:bind rps-keymap-normal
         (:autoload
             "a" #'avy-goto-char-timer))

  (:opt avy-style 'de-bruijn
        avy-all-windows nil
        avy-background t))
