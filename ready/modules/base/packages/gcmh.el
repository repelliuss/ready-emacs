;;; gcmh.el -*- lexical-binding: t; -*-

(use-package gcmh
  :ghook 'rdy--finalize-hook
  :config
  (setq gcmh-idle-delay 5))
