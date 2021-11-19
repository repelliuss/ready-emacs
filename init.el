;;; init.el -*- lexical-binding: t; -*-

(load (concat user-emacs-directory "ready/core") nil 'nomessage)

(load (concat user-emacs-directory "config") nil 'nomessage)

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)
