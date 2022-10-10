;;; scroll.el -*- lexical-binding: t; -*-

;; TODO: experiment scroll conservatively
(setq scroll-conservatively 101
      scroll-margin 3
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2)
