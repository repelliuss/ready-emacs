;;; startup.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt inhibit-startup-screen t
        inhibit-startup-echo-area-message user-login-name
        inhibit-default-init t
        initial-major-mode 'text-mode
        initial-scratch-message nil)
  (:advice-to #'display-startup-echo-area-message :override #'ignore)
  (cd (getenv "HOME")))

