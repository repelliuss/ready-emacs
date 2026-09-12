;;; early-init.el --- -*- lexical-binding: t; -*-

(defvar enable-config-file (concat user-emacs-directory "local/enable/config.el"))

(load (concat user-emacs-directory "local/package/enable") nil 'nomessage)
(load (concat user-emacs-directory "local/package/enable-catalog") nil 'nomessage)

(enable-module :local :path (concat user-emacs-directory "local/enable/"))
(enable :early)
(elpaca-wait)
