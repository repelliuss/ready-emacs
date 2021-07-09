;;; gcmh.el -*- lexical-binding: t; -*-

(use-package gcmh
  :hook (rdy--finalize . gcmh-mode)
  :config
  (setq gcmh-idle-delay 5))
