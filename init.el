;;; init.el -*- lexical-binding: t; -*-

;; (enable
;;  :editor
;;  :pkg (meow
;;        ace-window
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

