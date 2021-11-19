;;; config.el -*- lexical-binding: t; -*-

(enable!
 :editor
 :pkg (defaults)
 :sub (all)

 :lang
 :pkg (defaults)
 :sub (all)

 :tools
 :pkg (defaults)
 :sub (all)

 :ui
 :pkg (defaults)
 :sub (all)

 :ux
 :pkg (defaults)
 :sub (all))

(setq user-full-name "repelliuss"
      user-mail-address "repelliuss@gmail.com")

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
  (modus-themes-load-operandi))

(set-face-attribute 'fixed-pitch nil :family "JetBrainsMono" :height 180)
(set-face-attribute 'variable-pitch nil :family "SF Pro Text" :height 180)

(setq native-comp-async-report-warnings-errors nil)

(setq create-lockfiles nil
      make-backup-files nil)
