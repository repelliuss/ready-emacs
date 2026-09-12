;;; proced.el -*- lexical-binding: t; -*-

(cfg proced
  (:opt proced-enable-color-flag t)
  (:bind rps-keymap-open
         "P" #'proced))

(cfg-pkg proced-narrow
  (:after proced
    (:bind proced-mode-map
           "v" #'proced-narrow)))
