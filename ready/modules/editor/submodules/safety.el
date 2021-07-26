;;; safety.el -*- lexical-binding: t; -*-

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

(provide 'rdy/editor/safety)
