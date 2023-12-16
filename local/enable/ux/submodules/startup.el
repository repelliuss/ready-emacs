;;; startup.el -*- lexical-binding: t; -*-

(setup-none
  (:set inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)
  (:with-function display-startup-echo-area-message
    (:advice :override #'ignore)))



