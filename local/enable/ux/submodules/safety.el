;;; safety.el -*- lexical-binding: t; -*-

;; Use `recover-file' or `recover-session' to recover them.
(setq auto-save-default t
      auto-save-include-big-deletions t
      auto-save-list-file-prefix (concat cache-dir "autosave/")
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  (concat cache-dir "autosave/tramp/\\2") t)
            (list ".*" auto-save-list-file-prefix t)))

(setq auth-sources '("~/.authinfo.gpg" "~/.netrc.gpg"))

(setq epa-pinentry-mode 'loopback)
