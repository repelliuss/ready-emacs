;;; init.el -*- lexical-binding: t; -*-

;; TODO: Prepare Windows & Mac support
;; TODO: Handle backup and autosave files
;; TODO: Add defaults and all variables
;; TODO: Remove use-package config variables
;; TODO: use general.el

(load (concat user-emacs-directory "ready/base/config") t t)

(load (concat user-emacs-directory "config") t t)

(run-hooks 'rdy--finalize-hook)

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)
