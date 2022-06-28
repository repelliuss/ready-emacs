;;; init.el -*- lexical-binding: t; -*-

(enable
 :editor
 :pkg (meow
       ace-window
       consult
       embark
       vertico
       corfu
       kind-icon
       cape
       wgrep
       puni
       tempel
       file-painter
       avy
       presentation
       topspace
       olivetti)
 :sub (all)
 
 :lang
 :pkg (web-mode
       glsl
       php
       rust)
 :sub (all)

 :tools
 :pkg (magit
       flymake
       screenshot
       disk-usage
       pdf-tools
       csv-mode
       chess
       pkg-ssh-deploy
       pass
       cmake
       lsp-mode
       dap-mode
       org
       org-remark
       org-super-agenda
       org-ql
       org-roam
       org-gamedb
       orgmdb
       org-tree-slide)
 :sub (all)

 :ui
 :pkg (hl-todo
       tab-bar-echo-area
       ;; diff-hl
       hide-mode-line)
 :sub (all -font -frame)

 :ux
 :pkg (which-key
       orderless
       marginalia
       gcmh
       helpful
       pcmpl-args)
 :sub (all)

 :secret all)



;; TODO: make bookmark system

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
         (format "%.2f seconds"
                 (float-time
                  (time-subtract after-init-time before-init-time))) gcs-done)
