;;; minibuffer.el -*- lexical-binding: t; -*-

(setq enable-recursive-minibuffers t)

(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(setq read-extended-command-predicate
      #'command-completion-default-include-p)

(defun minibuffer-save ()
    (interactive)
    (clipboard-kill-ring-save (point-at-bol) (point-at-eol)))

(bind minibuffer-mode-map
      "M-s" #'minibuffer-save
      "M-y" #'yank
      "M-Y" #'yank-pop
      "M-[" #'previous-history-element
      "M-]" #'next-history-element
      "M-{" #'previous-matching-history-element
      "M-}" #'next-matching-history-element)

(fset #'yes-or-no-p #'y-or-n-p)
