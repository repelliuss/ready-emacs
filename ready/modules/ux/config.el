;;; config.el -*- lexical-binding: t; -*-

;;; Text

(set-language-environment "UTF-8")

;;; Startup

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

(advice-add #'display-startup-echo-area-message :override #'ignore)

;;; Notification

(setq ring-bell-function #'ignore
      visible-bell nil)

;;; Safety

(setq create-lockfiles nil
      make-backup-files nil)

;; Use `recover-file' or `recover-session' to recover them.
(setq auto-save-default t
      auto-save-include-big-deletions t
      auto-save-list-file-prefix (concat rdy/cache-directory "autosave/")
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  (concat rdy/cache-directory "autosave/tramp/\\2") t)
            (list ".*" auto-save-list-file-prefix t)))

(setq auth-sources '("~/.authinfo.gpg"))

;;; Mouse

;; middle-click paste at point, not at click
(setq mouse-yank-at-point t)

(provide 'rdy/ux)
