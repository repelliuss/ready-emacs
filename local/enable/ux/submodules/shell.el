;;; shell.el -*- lexical-binding: t; -*-

(setq shell-command-dont-erase-buffer 'erase)

(add-hook 'shell-mode-hook #'visual-line-mode)
