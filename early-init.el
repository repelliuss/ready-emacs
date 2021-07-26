;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq package-enable-at-startup nil)

(setq native-comp-deferred-compilation nil)
(add-to-list 'native-comp-eln-load-path (concat user-emacs-directory "ready/cache/eln/"))

(setq load-prefer-newer t)

(load (concat user-emacs-directory "early-config") t t)
