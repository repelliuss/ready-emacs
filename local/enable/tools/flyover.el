;;; flyover.el -*- lexical-binding: t; -*-

(cfg-pkg (:require
            (:elpaca flyover
                     :host github
                     :repo "konrad1977/flyover"))
  (:opt flyover-background-lightness 90
        flyover-text-tint 'darker
        flyover-text-tint-percent 100
        flyover-icon-left-padding 0.75
        flyover-icon-right-padding 0.75
        flyover-icon-tint 'lighter
        flyover-icon-tint-percent 100
        flyover-icon-background-tint 'lighter
        flyover-icon-background-tint-percent 30
        flyover-show-virtual-line nil
        flyover-show-at-eol t
        flyover-wrap-messages t
        flyover-max-line-length 128)
  (:face flyover-error (:background "lavender")
         flyover-warning (:background "cyan")
         flyover-info (:background "palegr"))
  (:hook-into flycheck)
  (:after nerd-icons
    (:opt flyover-error-icon (nerd-icons-codicon "nf-cod-error" :v-adjust 0.05)
          flyover-warning-icon (nerd-icons-codicon "nf-cod-warning" :v-adjust 0.05)
          flyover-info-icon (nerd-icons-codicon "nf-cod-info" :v-adjust 0.05))))
