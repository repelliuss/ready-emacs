;;; c-pp.el -*- lexical-binding: t; -*-

(c-add-style
 "csharp-unity"
 '("csharp"
   (c-offsets-alist
    (func-decl-cont . 0)
    (substatement . 0))))

(use-package cc-mode
  :config
  (when (eq tab-always-indent 'complete)
    (defun c-indent-then-complete ()
      (interactive)
      (if (= 0 (c-indent-line-or-region))
	  (completion-at-point)))

    (bind c-mode-map
	  "<tab>" #'c-indent-then-complete)))

