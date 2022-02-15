;;; gcmh.el -*- lexical-binding: t; -*-

(use-package gcmh
  :init
  (add-hook 'emacs-startup-hook #'gcmh-mode)
  
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024))) ; 16MB
