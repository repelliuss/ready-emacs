;;; inter.el -*- lexical-binding: t; -*-

(store-install "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
  :url-font t
  :then
  (cfg fontaine
    (:after 'fontaine
      (:prepend* fontaine-presets '((regular-inter :default-family "Inter"
                                                   :variable-pitch-family "Inter"
                                                   :mode-line-active-family "Inter"
                                                   :mode-line-active-height 1.0
                                                   :mode-line-inactive-family "Inter"
                                                   :mode-line-inactive-height 1.0
                                                   :header-line-family "Inter"
                                                   :header-line-height 1.0))))))
