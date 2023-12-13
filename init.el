;;; init.el -*- lexical-binding: t; -*-

(enable
 :theme
 :pkg (tao-theme)
 :sub (load-preferred-theme)

 :font
 :pkg (fontaine)

 :modeline
 :pkg (mood-line)
 
 :ui
 :sub (zen
       pad-frame
       pad-window
       hl-todo
       rainbow-mode
       cursor
       prettify
       quit)

 :ux
 :pkg (which-key
       orderless
       marginalia
       all-the-icons
       pcmpl-args
       helpful)

 :sub (unsafety
       no-beep
       history
       os
       home)

 :editor
 :pkg (meow
       ace-window
       vertico
       consult
       ;; consult-project-extra
       embark
       embark-consult
       wgrep
       kind-icon
       puni
       corfu
       avy
       tempel
       file-painter
       olivetti
       topspace
       presentation
       project)
 
 :sub (file
       edit
       buffer
       search
       toggle
       workspace
       open
       ace-window-hasty-windows
       minibuffer
       electric
       spaces
       completion
       tempel-file-painter
       frame-padding
       scroll
       fd)

 :tools
 :pkg (magit
       ssh-agency
       eglot
       dape
       flymake
       eshell)

 :sub (compile
       dired
       grammer
       web)

 :lang
 :pkg (elisp
       lua)

 :secret all)

;; TODO: make bookmark system

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
 '(safe-local-variable-values '((projectile-indexing-method . alien))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
