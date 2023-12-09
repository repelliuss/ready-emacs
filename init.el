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
 :sub (zen pad-frame pad-window)

 :ux
 :pkg (which-key
       orderless
       marginalia)

 :sub (unsafety
       no-beep
       history)

 :editor
 :pkg (meow
       ace-window
       vertico
       consult
       consult-project-extra
       embark
       embark-consult)
 
 :sub (project
       file
       buffer
       search
       toggle
       workspace
       ace-window-hasty-windows
       minibuffer
       electric
       vertico-consult-completion-in-region
       spaces)

 :tools
 :pkg (magit)

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

;; TODO: just one space keybinding doesn't work
