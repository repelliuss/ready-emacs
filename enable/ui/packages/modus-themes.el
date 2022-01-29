;;; modus-themes.el -*- lexical-binding: t; -*-

(use-package modus-themes
  :init
  (modus-themes-load-themes)
  :config
  (setq modus-themes-inhibit-reload t
        modus-themes-success-deuteranopia t
        modus-themes-syntax 'yellow-comments
        modus-themes-mode-line '(3d borderless accented)
        modus-themes-completions 'opinionated
        modus-themes-lang-checkers 'colored-background
        modus-themes-subtle-line-numbers t
        modus-themes-paren-match 'subtle-bold
        modus-themes-diffs 'deuteranopia
        modus-themes-org-blocks 'tinted-background
        modus-themes-scale-headings t
        modus-themes-variable-pitch-headings t
        modus-themes-region 'bg-only)
  (if (eq theme-preferred-background 'light)
      (modus-themes-load-operandi)
    (modus-themes-load-vivendi)))
