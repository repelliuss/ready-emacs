;;; modus-themes.el -*- lexical-binding: t; -*-

(use-package tao-theme
  :init
  (setq tao-theme-use-sepia nil)

  (@theme-load-if-preferred 'tao-theme 'tao-yang 'tao-yin))
