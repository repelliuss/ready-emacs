;;; which-key.el -*- lexical-binding: t; -*-

(use-package which-key
  :demand t
  :config
  (setq which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-allow-multiple-replacements t)
  (which-key-mode))
