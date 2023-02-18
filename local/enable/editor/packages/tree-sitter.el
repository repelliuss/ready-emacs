;;; tree-sitter.el -*- lexical-binding: t; -*-

(use-package tree-sitter
  :init
  (add-hook 'prog-mode-hook #'tree-sitter-mode))

(use-package tree-sitter-langs
  :after tree-sitter
  :init
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
