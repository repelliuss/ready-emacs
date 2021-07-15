;;; core.el -*- lexical-binding: t; -*-

(defvar rdy--finalize-hook)

(unless (daemonp)
  (advice-add #'display-startup-echo-area-message :override #'ignore))

(set-language-environment "UTF-8")
(setq selection-coding-system 'utf-8) ; with sugar on top

(setq create-lockfiles nil
      make-backup-files nil)

;; Use `recover-file' or `recover-session' to recover them.
(setq auto-save-default t
      auto-save-include-big-deletions t
      auto-save-list-file-prefix (concat rdy--cache-directory "autosave/")
      tramp-auto-save-directory  (concat rdy--cache-directory "tramp-autosave/")
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  ;; Prefix tramp autosaves to prevent conflicts with local ones
                  (concat auto-save-list-file-prefix "tramp-\\2") t)
            (list ".*" auto-save-list-file-prefix t)))
