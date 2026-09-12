;;; minibuffer.el -*- lexical-binding: t; -*-

(defun rps-minibuffer-save ()
  (interactive)
  (clipboard-kill-ring-save (pos-bol) (pos-eol))
  (message "Minibuffer input is saved to clipboard!"))

(cfg emacs
  (:bind minibuffer-mode-map
	     (:prefix "M-"
	       "s" #'rps-minibuffer-save
	       "y" #'yank
	       "Y" #'yank-pop
	       "[" #'previous-history-element
	       "]" #'next-history-element
	       "{" #'previous-matching-history-element
	       "}" #'next-matching-history-element)
	     "<backspace>" #'backward-kill-word)

  (:opt enable-recursive-minibuffers t
	    minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)
	    read-extended-command-predicate #'command-completion-default-include-p)

  (:hook-to 'minibuffer-setup-hook #'cursor-intangible-mode)

  (fset #'yes-or-no-p #'y-or-n-p))

