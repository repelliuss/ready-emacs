;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(setq native-comp-deferred-compilation nil)

(setq package-enable-at-startup nil)

(setq load-prefer-newer noninteractive)

(load (concat user-emacs-directory "early-config") nil 'nomessage)
