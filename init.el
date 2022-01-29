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
 :sub (all -no-bar -font)

 :ux
 :pkg (defaults)
 :sub (all)

 :secret all)

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("f0eb51d80f73b247eb03ab216f94e9f86177863fb7e48b44aacaddbfe3357cf1" default))
 '(widget-image-enable nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
