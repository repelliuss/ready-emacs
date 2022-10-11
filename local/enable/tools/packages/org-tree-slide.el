;;; org-tree-slide.el -*- lexical-binding: t; -*-

(use-package org-tree-slide
  :after org
  :init
  (bind org-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "p" #'org-tree-slide-mode))

  :config
  (bind org-tree-slide-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "n" #'org-tree-slide-move-next-tree
	  "p" #'org-tree-slide-move-previous-tree
	  "q" #'org-tree-slide-mode
	  "c" #'org-tree-slide-content)
	"<right>" #'org-tree-slide-move-next-tree
	"<left>" #'org-tree-slide-move-previous-tree
	"<up>" #'cursor-hide)

  (advice-add #'org-tree-slide-mode
	      :after
	      (defun @org-tree-slide-prepare (mode-arg)
		(if (fboundp #'cursor-hide) (cursor-hide))
		(setq text-scale-mode-amount 3)
		(text-scale-mode mode-arg))))
