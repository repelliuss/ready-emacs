;;; dap-mode.el -*- lexical-binding: t; -*-

(use-package dap-mode
  :init
  (setq dap-auto-configure-features '(locals expressions)
	dap-utils-extension-path (concat cache-dir "dap-mode/extension")
	dap-breakpoints-file (concat cache-dir "dap-mode/breakpoints"))
  (dap-auto-configure-mode 1))

(use-package cc-mode
  :config
  (require 'dap-cpptools))
