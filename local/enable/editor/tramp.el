;;; tramp.el -*- lexical-binding: t; -*-

(cfg tramp
  (:opt tramp-auto-save-directory (concat rps-dir-cache "tramp/autosave/")
        tramp-persistency-file-name (concat rps-dir-cache "tramp/tramp")))
