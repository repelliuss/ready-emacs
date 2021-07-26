;;; scroll.el -*- lexical-binding: t; -*-

(setq scroll-conservatively 101
      scroll-margin 0
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2)

(advice-add #'scroll-up-command :after #'recenter)
(advice-add #'scroll-down-command :after #'recenter)
(advice-add #'scroll-up-command :filter-args (lambda (_)))
(advice-add #'scroll-down-command :filter-args (lambda (_)))

(provide 'rdy/editor/scroll)
