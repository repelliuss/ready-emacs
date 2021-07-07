;;; which.el -*- lexical-binding: t; -*-

(use-package which-key
  :demand
  :init
  (setq which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil)
  :config
  (which-key-mode 1))
