;;; frame.el -*- lexical-binding: t; -*-

(setq default-frame-alist
      (nconc default-frame-alist
	     '((internal-border-width . 12)
	       (left-fringe . 1)
	       (menu-bar-lines . 0)
	       (tool-bar-lines . 0)
	       (vertical-scroll-bars))))

(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

(setq use-dialog-box nil)
(tooltip-mode -1)
