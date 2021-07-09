;;; init.el -*- lexical-binding: t; -*-

;; TODO: Prepare Windows & Mac support
;; TODO: Move gcmh to base/packages
;; TODO: Look naming convention
;; TODO: Handle backup and autosave files
;; TODO: Check packages for dependendent loading
;; TODO: Add defaults and all variables

(load (concat user-emacs-directory "ready/base/config") t t)

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
