;;; aporetic.el -*- lexical-binding: t; -*-

(store-install "https://github.com/protesilaos/aporetic/archive/refs/heads/main.zip"
  :url-font t
  :then
  (lambda ()
    (cfg fontaine
      (:after-this
        (:prepend* fontaine-presets '((regular-aporetic :default-weight regular
                                                        :default-height 160
                                                        :default-family "Aporetic Sans Mono"
                                                        :fixed-pitch-family "Aporetic Sans Mono"
                                                        :fixed-pitch-serif-family "Aporetic Serif Mono"
                                                        :variable-pitch-family "Aporetic Serif"
                                                        :header-line-family "Aporetic Serif Mono"
                                                        :header-line-height 1.0
                                                        :mode-line-active-family "Aporetic Serif Mono"
                                                        :mode-line-active-height 1.0
                                                        :mode-line-inactive-family "Aporetic Serif Mono"
                                                        :mode-line-inactive-height 1.0)
                                      (regular-aporetic-sm :default-weight regular
                                                           :default-height 100
                                                           :inherit regular-aporetic)))
        (when rps-system-android-p
          (defun rps-font-set-aporetic-variable-pitch ()
            (interactive)
            (:face variable-pitch (:family "Aporetic Serif")))
          (defun rps-font-set-aporetic ()
            (interactive)
            (:face default (:family "Aporetic Sans Mono" :height 240)
                   fixed-pitch (:family "Aporetic Sans Mono")
                   header-line (:family "Aporetic Serif Mono")
                   mode-line (:family "Aporetic Serif Mono"))
            (rps-font-set-aporetic-variable-pitch))
          (rps-font-set-aporetic-variable-pitch))))))
