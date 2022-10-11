;;; c-pp.el -*- lexical-binding: t; -*-

(c-add-style
 "csharp-unity"
 '("csharp"
   (c-offsets-alist
    (func-decl-cont . 0)
    (substatement . 0))))

(use-package cc-mode
  :config
  (bind (c-mode-map c++-mode-map)
	(bind-local
	  "C-S-o" #'ff-find-other-file
	  "C-o" #'ff-find-other-file-other-window
	  "o" #'c-set-offset)
	"<tab>" #'c-indent-then-complete)

  (when (eq tab-always-indent 'complete)
    (defun c-indent-then-complete ()
      (interactive)
      (if (= 0 (c-indent-line-or-region))
	  (completion-at-point))))
  
  :extend (find-file)
  (add-to-list 'cc-search-directories "../include")
  (add-to-list 'cc-search-directories "../src"))

