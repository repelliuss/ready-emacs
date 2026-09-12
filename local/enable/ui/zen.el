;;; zen.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt ring-bell-function #'ignore
        visible-bell nil)

  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1))
