;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq package-enable-at-startup nil)

(when (featurep 'native-compile)
  (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory "ready/cache/eln/")))

(setq load-prefer-newer noninteractive)

(load (concat user-emacs-directory "ready/core") nil 'nomessage)

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

(setq ready-force-build-cache t)

(enable-early!
 :ui
 :sub (no-bar))

(custom-set-variables '(nano-modeline-position 'bottom))

(add-to-list 'default-frame-alist '(font . "-*-Iosevka Term-regular-r-*--21-*-*-*-*-*-*-*"))
(set-face-attribute 'fixed-pitch nil :family "JetBrainsMono" :height 180)
(set-face-attribute 'variable-pitch nil :family "SF Pro Text" :height 180)

;; TODO: Put this file in ready-early-setup
