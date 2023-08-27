;;; init.el -*- lexical-binding: t; -*-

;; TODO remove with eval after loads
;; TODO: hasty and vertico should fix :bind
;; TODO: use custom vertico order
;; TODO: can I write recipe to :elpaca in body
;; TODO: move orderless $ regexp to consult dispatcher and prepend it there

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
       orderless)

 :editor
 :pkg (meow
       ace-window
       vertico)
 :sub (project
       file
       buffer
       ace-window-hasty-windows)

 :tools
 :pkg (magit))

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
