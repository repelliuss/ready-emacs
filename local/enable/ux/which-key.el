;;; which-key.el -*- lexical-binding: t; -*-

(cfg-pkg which-key
  (:opt which-key-sort-order #'which-key-description-order
        which-key-sort-uppercase-first nil
        which-key-allow-multiple-replacements t
        which-key-echo-keystrokes 0.05
        which-key-idle-secondary-delay 0.05)

  (which-key-mode 1))
