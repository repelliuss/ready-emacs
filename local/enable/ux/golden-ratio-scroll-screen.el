;;; golden-ratio-scroll-screen.el -*- lexical-binding: t; -*-

(cfg-pkg golden-ratio-scroll-screen
  (:opt golden-ratio-scroll-highlight-flag nil)
  (:advice-to #'scroll-up-command :override #'golden-ratio-scroll-screen-up)
  (:advice-to #'scroll-down-command :override #'golden-ratio-scroll-screen-down))
