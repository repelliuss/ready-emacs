;;; typescript.el -*- lexical-binding: t; -*-

(use-package typescript-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode)))
(use-package rjsx-mode)
