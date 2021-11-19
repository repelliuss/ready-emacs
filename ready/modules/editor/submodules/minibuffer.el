;;; minibuffer.el -*- lexical-binding: t; -*-

(setq enable-recursive-minibuffers t)

(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(setq read-extended-command-predicate
      #'command-completion-default-include-p)

(provide 'ready/editor/minibuffer)
