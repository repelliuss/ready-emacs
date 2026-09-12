;;; orderless.el -*- lexical-binding: t; -*-

(defun rps-orderless-split-on-space-and-joined-regexp (string)
  (cons (string-replace " " ".*" (string-trim string))
        (orderless-escapable-split-on-space string)))

(cfg-pkg (:require orderless orderless-kwd)
  (:opt completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))
        orderless-component-separator #'orderless-escapable-split-on-space
        orderless-matching-styles '(orderless-initialism orderless-regexp)
        orderless-affix-dispatch-alist '((?% . char-fold-to-regexp)
                                         (?! . orderless-not)
                                         (?& . orderless-annotation)
                                         (?= . orderless-literal)
                                         (?~ . orderless-initialism)
                                         (?, . orderless-flex))))
