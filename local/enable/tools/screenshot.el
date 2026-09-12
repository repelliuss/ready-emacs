;;; screenshot.el -*- lexical-binding: t; -*-

(store-install "imagemagick"
  :xbps '(:name "ImageMagick" :system void-linux)
  :then
  (lambda ()
    (cfg-pkg (:elpaca screenshot
                      :host github
                      :repo "tecosaur/screenshot"
		              :files ("*.el"))
      (:bind rps-keymap-open
             "s" #'screenshot))))
