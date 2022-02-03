;;; kind-icon.el -*- lexical-binding: t; -*-

(use-package kind-icon
  :demand t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :init
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package svg-lib
  :after kind-icon
  :init
  (setq svg-lib-icons-dir (concat cache-dir "svg-lib/")))

