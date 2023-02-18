;;; typescript.el -*- lexical-binding: t; -*-

(use-package web-mode
  :init
  (define-derived-mode web-tsx-mode web-mode "Web-TSX")
  (provide 'web-tsx-mode)

  :extend (tree-sitter)
  (add-to-list 'tree-sitter-major-mode-language-alist '(web-tsx-mode . tsx)))

(use-package typescript-mode
  :init
  (define-derived-mode typescript-tsx-mode typescript-mode "TSX")
  (provide 'typescript-tsx-mode)
  
  :extend (tree-sitter)
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-tsx-mode . tsx)))

(use-package tsi
  :straight (:host github :repo "orzechowskid/tsi.el")
  :init
  (add-hook 'web-tsx-mode-hook #'tsi-typescript-mode)
  (add-hook 'typescript-tsx-mode-hook #'tsi-typescript-mode))

(use-package lsp-tailwindcss
  :straight (:host github :repo "merrickluo/lsp-tailwindcss")
  
  :init
  (setq lsp-tailwindcss-add-on-mode t)

  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'web-tsx-mode)
  (add-to-list 'lsp-tailwindcss-major-modes 'typescript-tsx-mode))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode))

;; (use-package rjsx-mode)
