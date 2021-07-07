;;; ace-window.el -*- lexical-binding: t; -*-

(use-package ace-window
  :after (meow golden-ratio)
  :bind (:map meow-leader-keymap
         ("w w" . ace-window)
         ("w f" . aw-flip-window))
  :init
  (defvar aw-dispatch-alist
    '((?d aw-delete-window "Delete")
      (?e aw-swap-window "Exchange")
      (?m aw-move-window "Move")
      (?c aw-copy-window "Copy")
      (?? aw-show-dispatch-help))
    "List of actions for `aw-dispatch-default'.")
  :config
  (setq aw-keys '(?y ?u ?i ?o ?p ?\[ ?\])
        aw-scope 'frame
        aw-minibuffer-flag t)
  (advice-add #'ace-window :after #'golden-ratio))
