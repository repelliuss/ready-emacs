;;; window.el -*- lexical-binding: t; -*-

(use-package emacs
  :after (meow)
  :bind (:map meow-leader-keymap
         ("w h" . windmove-left)
         ("w j" . windmove-down)
         ("w k" . windmove-up)
         ("w l" . windmove-right)
         ("w H" . windmove-swap-states-left)
         ("w J" . windmove-swap-states-down)
         ("w K" . windmove-swap-states-up)
         ("w L" . windmove-swap-states-right)
         ("w d" . delete-window)
         ("w D" . delete-other-windows)
         ("w s" . split-window-below)
         ("w v" . split-window-right)))
