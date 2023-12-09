;;; history.el -*- lexical-binding: t; -*-

(setq save-place-file (concat ~dir-cache "save-place"))
(save-place-mode 1)

(setq recentf-save-file (concat ~dir-cache "recentf"))
(recentf-mode 1)
(add-hook 'buffer-list-update-hook #'recentf-track-opened-file)

(setq savehist-file (concat ~dir-cache "savehist"))
(savehist-mode 1)
