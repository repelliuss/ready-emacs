;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq package-enable-at-startup nil)

(setq native-comp-deferred-compilation nil)

(setq load-prefer-newer t)

(load (concat user-emacs-directory "early-config") t t)
