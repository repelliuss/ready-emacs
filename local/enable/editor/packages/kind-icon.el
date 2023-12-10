;;; kind-icon.el -*- lexical-binding: t; -*-

(setup (:require kind-icon)
  (:set svg-lib-icons-dir (concat ~dir-cache "svg-lib/"))
  
  (:after-feature corfu
    (:set kind-icon-default-face 'corfu-default
          (prepend corfu-margin-formatters) #'kind-icon-margin-formatter))
  
  (:after-feature enable-sub-vertico-consult-completion-in-region
    (:set completion-in-region-function (kind-icon-enhance-completion #'~vertico--consult-completion-in-region))))
