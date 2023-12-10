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
       rainbow-mode)

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
       tempel-file-painter)

 :tools
 :pkg (magit
       ssh-agency
       eglot
       dape
       flymake)

 :lang
 :pkg (elisp))

;; (enable
;;  :editor
;;  :pkg (meow
;;        ace-indow
;;        consult
;;        embark
;;        vertico
;;        corfu
;;        kind-icon
;;        cape
;;        wgrep
;;        puni
;;        tempel
;;        file-painter
;;        avy
;;        presentation
;;        topspace
;;        tree-sitter
;;        olivetti)
;;  :sub (all)
 
;;  :lang
;;  :pkg (typescript
;;        glsl
;;        php
;;        rust)
;;  :sub (all)

;;  :tools
;;  :pkg (magit
;;        forge
;;        git
;;        flymake
;;        screenshot
;;        disk-usage
;;        pdf-tools
;;        csv-mode
;;        chess
;;        pkg-ssh-deploy
;;        pass
;;        cmake
;;        lsp-mode
;;        dap-mode
;;        elfeed
;;        org
;;        org-gtd
;;        org-remark
;;        org-super-agenda
;;        org-ql
;;        org-roam
;;        org-gamedb
;;        orgmdb
;;        org-tree-slide)
;;  :sub (all)

;;  :ui
;;  :pkg (hl-todo
;;        tab-bar-echo-area
;;        rainbow-mode
;;        ;; diff-hl
;;        hide-mode-line)
;;  :sub (all -font -frame)

;;  :theme
;;  :pkg (nano-theme
;;        tao-theme)

;;  :ux
;;  :pkg (which-key
;;        orderless
;;        marginalia
;;        gcmh
;;        helpful
;;        pcmpl-args)
;;  :sub (all)

;;  :secret all)

;; TODO: make bookmark system

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)

