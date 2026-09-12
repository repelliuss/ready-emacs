;;; history.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt save-place-file (concat rps-dir-cache "save-place")
        recentf-save-file (concat rps-dir-cache "recentf")
        savehist-file (concat rps-dir-cache "savehist"))

  ;; Track buffer switches
  (:after recentf
    (:hook-to 'buffer-list-update-hook #'recentf-track-opened-file))

  (save-place-mode 1)
  (recentf-mode 1)
  (savehist-mode 1))
