;;; kind-icon.el -*- lexical-binding: t; -*-

(use-package kind-icon
  :demand t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :init
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package svg-lib
  :straight nil
  :init
  (setq svg-lib-icons-dir (concat @dir-cache "svg-lib/")))
