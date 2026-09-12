;;; safety.el -*- lexical-binding: t; -*-

(cfg emacs
  ;; Use `recover-file' or `recover-session' to recover them.
  (:opt auto-save-default t
        auto-save-include-big-deletions t
        auto-save-list-file-prefix (concat rps-dir-cache "autosave/")
        auto-save-file-name-transforms (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                                                   (concat rps-dir-cache "autosave/tramp/\\2") t)
                                             (list ".*" auto-save-list-file-prefix t))

        auth-sources '("~/.authinfo.gpg")
        auth-source-cache-expiry (* 60 60 8)

        epa-pinentry-mode 'loopback)

  (:advice-to #'after-find-file :around
           (defun rps--silence-autosave (fn &rest args)
             "Stop waiting for auto save file if there is an auto save."
             (cl-letf ((sit-for #'ignore))
               (apply fn args)))))
