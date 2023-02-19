;;; safety.el -*- lexical-binding: t; -*-

;; Use `recover-file' or `recover-session' to recover them.
(setq auto-save-default t
      auto-save-include-big-deletions t
      auto-save-list-file-prefix (concat @dir-cache "autosave/")
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  (concat @dir-cache "autosave/tramp/\\2") t)
            (list ".*" auto-save-list-file-prefix t)))

(setq auth-sources '("~/.authinfo.gpg" "~/.netrc.gpg")
      auth-source-cache-expiry (* 60 60 8))

(setq epa-pinentry-mode 'loopback)
