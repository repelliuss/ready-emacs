;;; modus-themes.el -*- lexical-binding: t; -*-

(use-package modus-themes
  :demand t
  :attach (rps/ui/theme)
  (setq theme-default-light 'modus-operandi
        theme-default-dark 'modus-vivendi)
  
  :init
  (setq modus-themes-inhibit-reload t
        modus-themes-success-deuteranopia t
        modus-themes-syntax '(yellow-comments)
        modus-themes-mode-line '(accented)
        modus-themes-completions '((matches . (extrabold background intense))
				   (selection . (semibold accented intense))
				   (popup . (accented)))
        modus-themes-lang-checkers '(background)
        modus-themes-subtle-line-numbers t
        modus-themes-paren-match '(subtle-bold)
        modus-themes-deuteranopia t
        modus-themes-org-blocks 'tinted-background
        modus-themes-scale-headings t
        modus-themes-variable-pitch-headings t
        modus-themes-region '(bg-only))
  
  (modus-themes-load-themes)
  
  :config
  (if (eq theme-preferred-background 'light)
      (modus-themes-load-operandi)
    (modus-themes-load-vivendi)))
