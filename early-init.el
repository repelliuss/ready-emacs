;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq package-enable-at-startup nil)

(when (featurep 'native-compile)
  (setq native-comp-deferred-compilation t)
  (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory "ready/cache/eln/")))

(setq load-prefer-newer noninteractive)

(add-to-list 'default-frame-alist
             '(font . "-*-Iosevka Term-regular-r-*--21-*-*-*-*-*-*-*"))

(load (concat user-emacs-directory "ready/core") nil 'nomessage)

(enable-early!
 :ui
 :sub (no-bar))

;; TODO: Put this file in ready-early-setup
