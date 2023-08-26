;;; fontaine.el -*- lexical-binding: t; -*-

(enable-quit-unless pkg fontaine
  (setup-none
    (:option (prepend fontaine-presets) '(iosevka-term-ss04 :default-family "Iosevka Term SS04"))
    (if (eq @font-preferred 'iosevka-term-ss04) (fontaine-set-preset @font-preferred))))
