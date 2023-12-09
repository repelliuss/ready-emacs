;;; cache.el -*- lexical-binding: t; -*-

(setq transient-history-file (concat ~dir-cache "transient/history.el")
      transient-levels-file (concat ~dir-cache "transient/levels.el")
      transient-values-file (concat ~dir-cache "transient/values.el"))

(setq tramp-auto-save-directory (concat ~dir-cache "tramp/autosave/")
      tramp-persistency-file-name (concat ~dir-cache "tramp/tramp"))

(setq bookmark-default-file (concat ~dir-cache "bookmarks"))

(setq eshell-aliases-file (concat ~dir-local "eshell/alias")
      eshell-history-file-name (concat ~dir-cache "eshell/history")
      eshell-last-dir-ring-file-name (concat ~dir-cache "eshell/lastdir"))
