;;; which-key.el -*- lexical-binding: t; -*-

(use-package which-key
  :init
  (which-key-mode 1)
  
  :config
  (setq which-key-sort-order #'which-key-description-order
        which-key-sort-uppercase-first nil
        which-key-allow-multiple-replacements t
	which-key-echo-keystrokes 0.05))
