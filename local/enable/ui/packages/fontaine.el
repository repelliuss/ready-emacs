;;; fontaine.el -*- lexical-binding: t; -*-

(@setup (:elpaca fontaine)
  (:option fontaine-latest-state-file (concat @dir-cache "fontaine-latest-state.eld")
	   fontaine-presets '((iosevka-term-ss04 :default-family "Iosevka Term SS04")
			      (t :default-weight regular
				 :default-height 160)))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset)
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'iosevka-term-ss04)))
