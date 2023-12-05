;;; minibuffer.el -*- lexical-binding: t; -*-

(setup-none
  (bind minibuffer-mode-map
	(:prefix "M-"
	  "s" #'$minibuffer-save
	  "y" #'yank
	  "Y" #'yank-pop
	  "[" #'previous-history-element
	  "]" #'next-history-element
	  "{" #'previous-matching-history-element
	  "}" #'next-matching-history-element)
	"<backspace>" #'backward-kill-word)
  
  (:option enable-recursive-minibuffers t
	   minibuffer-prompt-properties '(aread-only t cursor-intangible t face minibuffer-prompt)
	   read-extended-command-predicate #'command-completion-default-include-p)

  (:with-hook minibuffer-setup-hook (:hook #'cursor-intangible-mode))

  (fset #'yes-or-no-p #'y-or-n-p)
  
  (defun $minibuffer-save ()
    (interactive)
    (clipboard-kill-ring-save (point-at-bol) (point-at-eol))))







