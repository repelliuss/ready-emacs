;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq package-enable-at-startup nil)

(when (featurep 'native-compile)
  (setq native-comp-deferred-compilation nil)
  (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory "ready/cache/eln/")))

(setq load-prefer-newer noninteractive)

(load (concat user-emacs-directory "ready/core") nil 'nomessage)

(load (concat user-emacs-directory "early-config") nil 'nomessage)

(enable!
 :ui
 :sub (no-bar))

;; TODO: Put this file in ready-early-setup
