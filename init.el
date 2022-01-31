;;; init.el -*- lexical-binding: t; -*-

(enable
 :editor
 :pkg (defaults)
 :sub (all)
 
 :lang
 :pkg (defaults)
 :sub (all)

 :tools
 :pkg (defaults)
 :sub (all)

 :ui
 :pkg (defaults)
 :sub (all -no-bar -font -frame)

 :ux
 :pkg (defaults)
 :sub (all)

 :secret all)

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)
