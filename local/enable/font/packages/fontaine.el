;;; fontaine.el -*- lexical-binding: t; -*-

(setup fontaine
  (:set fontaine-latest-state-file (concat ~dir-cache "fontaine-latest-state.eld")
        fontaine-presets '((iosevka-term-ss04 :default-family "Iosevka Term SS04" :default-height 160)
                           (t :default-weight regular :default-height 160)))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset)
  (fontaine-set-preset (or (fontaine-restore-latest-preset) ~font-preferred))

  (defun ~font-reset-to-preferred ()
    (interactive)
    (delete-file fontaine-latest-state-file)
    (fontaine-set-preset ~font-preferred)))
