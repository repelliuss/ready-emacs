;;; modus-themes.el -*- lexical-binding: t; -*-

(use-package tao-theme
  :attach (rps/ui/theme)
  (setq theme-default-light 'tao-yang
	theme-default-dark 'tao-yin)
  :init
  (setq tao-theme-use-sepia nil)
  (if (eq theme-preferred-background 'light)
      (load-theme 'tao-yang t)
    (load-theme 'tao-yin t)))
