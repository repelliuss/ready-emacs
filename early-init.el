;;; early-init.el --- -*- lexical-binding: t; -*-

(setq enable-modules-dir (setq enable-dir (concat user-emacs-directory "local/enable/"))
      enable-cache-dir (concat user-emacs-directory "cache/enable/")
      enable-loader #'enable-using-eval)

(load (concat user-emacs-directory "enable") nil 'nomessage)
(enable-setup)

(setq package-enable-at-startup nil)	; I use elpaca

;; TODO: Try using in init.el
(enable-early
 :init all

 :theme
 :pkg (modus-themes)
 
 :ui
 :sub (font frame)
 :pkg (mood-line))

;; TODO: meow SPC G


