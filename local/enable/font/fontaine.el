;;; fontaine.el -*- lexical-binding: t; -*-

(cfg-pkg fontaine
  (defvar fontaine-presets '((t :line-spacing (0.15 . 0.15))))
  (defvar fontaine-latest-state-file (concat rps-dir-cache "fontaine-latest-state.eld"))
  (fontaine-mode 1))

