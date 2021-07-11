;;; orderless.el -*- lexical-binding: t; -*-

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless)
	completion-category-overrides nil
	completion-category-defaults nil
	orderless-component-separator #'orderless-escapable-split-on-space
        orderless-matching-styles '(orderless-regexp
                                    orderless-strict-initialism
                                    orderless-literal)))
