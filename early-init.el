;;; early-init.el --- -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      native-comp-deferred-compilation nil
      gc-cons-threshold most-positive-fixnum
      load-prefer-newer noninteractive)

(load (concat user-emacs-directory "early-config") t t)
