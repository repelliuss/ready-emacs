;;; init.el -*- lexical-binding: t; -*-

;; TODO: Prepare Windows & Mac support
;; TODO: Handle backup and autosave files
;; TODO: Gen macro symbols
;; Meow change save not working for chars
;; Meow goto old position

(load (concat user-emacs-directory "ready/base/config") nil 'nomessage)

(load (concat user-emacs-directory "config") nil 'nomessage)

(run-hooks 'rdy--finalize-hook)

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)
