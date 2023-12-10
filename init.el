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
       history)

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
       topspace)
 
 :sub (project
       file
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
       scroll)

 :tools
 :pkg (magit
       ssh-agency
       eglot
       dape
       flymake)

 :sub (compile
       dired
       grammer
       web)

 :lang
 :pkg (elisp)

 :secret all)

;; TODO: make bookmark system

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)

