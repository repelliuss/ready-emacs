;;; ace-window.el -*- lexical-binding: t; -*-

(use-package ace-window
  :commands (aw-flip-window)

  :attach (meow)
  (general-def meow-leader-keymap
    :prefix "w"
    "w" #'ace-window
    "f" #'aw-flip-window)

  :config
  (setq aw-keys '(?q ?e ?r ?u ?i ?o)
        aw-scope 'frame))
