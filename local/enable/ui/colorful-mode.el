;;; colorful-mode.el -*- lexical-binding: t; -*-

(cfg-pkg colorful-mode
  (:bind rps-keymap-edit
         (:prefix "C"
           (:autoload
            "x" #'colorful-change-or-copy-color
            "c" #'colorful-convert-and-copy-color
            "r" #'colorful-convert-and-change-color)))

  (:opt colorful-short-hex-conversions nil
        colorful-prefix-string "🎨")

  (:hook-into prog-mode text-mode))
