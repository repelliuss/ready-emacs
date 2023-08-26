;;; fontaine.el -*- lexical-binding: t; -*-

(setup fontaine
  (:option fontaine-latest-state-file (concat @dir-cache "fontaine-latest-state.eld")
	   fontaine-presets '((t :default-weight regular :default-height 160)))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset))
