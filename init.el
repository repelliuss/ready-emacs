;;; init.el -*- lexical-binding: t; -*-

(enable
 :theme
 :pkg (nano-theme)

 :font
 :pkg (fontaine)

 :modeline
 :pkg (mood-line)
 
 :ui
 :sub (zen pad-frame pad-window)

 :ux
 :pkg (which-key)

 :editor
 :pkg (meow
       ace-window)
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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("dde643b0efb339c0de5645a2bc2e8b4176976d5298065b8e6ca45bc4ddf188b7" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(region ((t :extend nil))))
