;;; clipboard.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt save-interprogram-paste-before-kill t)

  (when rps-system-wsl-p
    (:opt select-active-regions nil)))
