;;; init.el -*- lexical-binding: t; -*-

;; TODO: Change rps

(load (concat user-emacs-directory "rps/base/config") t t)

(load (concat user-emacs-directory "config") t t)

(use-package gcmh
  :demand
  :config
  (setq gcmh-idle-delay 5)
  (gcmh-mode 1))

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
     (format "%.2f seconds"
             (float-time
              (time-subtract after-init-time before-init-time))) gcs-done)
