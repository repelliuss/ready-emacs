;;; ioskeley.el -*- lexical-binding: t; -*-

(store-install "https://github.com/ahatem/IoskeleyMono/releases/download/v2.1.0/IoskeleyMono.zip"
  :url-font t
  :then
  (lambda ()
    (cfg fontaine
      (:after-this
        (:prepend* fontaine-presets '((regular-ioskeley-mono :default-family "Ioskeley Mono"
                                                             :default-weight regular
                                                             :default-height 140
                                                             :fixed-pitch-family "Ioskeley Mono"
                                                             :header-line-family "Ioskeley Mono"
                                                             :header-line-height 1.0
                                                             :variable-pitch-family "Ioskeley Mono"
                                                             :mode-line-active-family "Ioskeley Mono"
                                                             :mode-line-inactive-family "Ioskeley Mono"
                                                             :mode-line-active-height 1.0
                                                             :mode-line-inactive-height 1.0)
                                      (regular-ioskeley-mono-sm :inherit regular-ioskeley-mono
                                                                :default-height 120)))
        (unless rps-system-android-p
          (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular-ioskeley-mono)))
        (when rps-system-android-p
          (defun rps-font-set-ioskeley ()
            (interactive)
            (:face default (:family "Ioskeley Mono" :height 180)
                   fixed-pitch (:family "Ioskeley Mono")
                   header-line (:family "Ioskeley Mono")
                   mode-line (:family "Ioskeley Mono")))
          (rps-font-set-ioskeley))))))
