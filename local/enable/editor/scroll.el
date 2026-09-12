;;; scroll.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt scroll-conservatively 101
        scroll-margin 3
        scroll-preserve-screen-position t
        auto-window-vscroll nil
        mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
        mouse-wheel-scroll-amount-horizontal 2
        recenter-positions '(0.35 0.65 0.9)))
