;;; fontaine.el -*- lexical-binding: t; -*-

(@setup (:elpaca fontaine)
  (:option fontaine-latest-state-file (concat @dir-cache "fontaine-latest-state.eld"))
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset))
