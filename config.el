;;; config.el -*- lexical-binding: t; -*-

(rps/load-packages 'ui defaults)
(rps/load-packages 'editor defaults)

(setq user-full-name "repelliuss"
      user-mail-address "repelliuss@gmail.com")

(use-package modus-themes
  :demand
  :init
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
  :config
  (modus-themes-load-themes)
  (modus-themes-load-operandi))

(set-face-attribute 'fixed-pitch nil :family "JetBrainsMono" :height 180)
(set-face-attribute 'variable-pitch nil :family "SF Pro Text" :height 180)
