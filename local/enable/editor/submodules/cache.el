;;; cache.el -*- lexical-binding: t; -*-

(setq transient-history-file (concat local-dir "transient/history.el")
      transient-levels-file (concat local-dir "transient/levels.el")
      transient-values-file (concat local-dir "transient/values.el"))

(setq project-list-file (concat cache-dir "project"))

(setq tramp-auto-save-directory (concat cache-dir "tramp/autosave/")
      tramp-persistency-file-name (concat cache-dir "tramp/tramp"))

(setq recentf-save-file (concat cache-dir "recentf"))

(setq save-place-file (concat cache-dir "save-place"))

(setq bookmark-default-file (concat local-dir "bookmarks"))

(setq savehist-file (concat cache-dir "savehist"))

(setq eshell-aliases-file (concat local-dir "eshell/alias")
      eshell-history-file-name (concat cache-dir "eshell/history")
      eshell-last-dir-ring-file-name (concat cache-dir "eshell/lastdir"))
