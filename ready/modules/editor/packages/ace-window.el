;;; ace-window.el -*- lexical-binding: t; -*-

(use-package ace-window
  :init
  (after! meow
    (general-def
     :keymaps 'meow-leader-keymap
     :prefix "w"
     "w" #'ace-window
     "f" #'aw-flip-window))
  :config
  (setq aw-keys '(?y ?u ?i ?o ?p ?\[ ?\])
        aw-scope 'frame
        aw-minibuffer-flag t
        aw-dispatch-alist
        '((?d aw-delete-window "Delete")
          (?e aw-swap-window "Exchange")
          (?m aw-move-window "Move")
          (?c aw-copy-window "Copy")
          (?? aw-show-dispatch-help)))
  (after! golden-ratio
    (advice-add #'ace-window :after #'golden-ratio)))
