;;; selectrum.el -*- lexical-binding: t; -*-

(use-package orderless
  :demand
  :config
  (setq completion-styles '(orderless)
	completion-category-overrides nil
	completion-category-defaults nil
	orderless-component-separator #'orderless-escapable-split-on-space
        orderless-matching-styles '(orderless-regexp
                                    orderless-strict-initialism
                                    orderless-literal)))

(use-package selectrum
  :demand
  :after (orderless)
  :bind (:map meow-leader-keymap
	 ("r" . selectrum-repeat)
	 :map selectrum-minibuffer-map
         ("M-j" . selectrum-next-candidate)
         ("M-k" . selectrum-previous-candidate)
	 ("M-d" . selectrum-next-page)
	 ("M-u" . selectrum-previous-page)
	 ("M-s" . selectrum-quick-select)
	 ("M-c" . selectrum-cycle-display-style)
	 ("M-<backspace>" . kill-whole-line)
	 ("C-<backspace>" . selectrum-backward-kill-sexp)
	 ("M-y" . kill-ring-save)
	 ("M-RET" . selectrum-submit-exact-input))
  :config
  (setq orderless-skip-highlighting (lambda () selectrum-is-active)
        selectrum-refine-candidates-function #'orderless-filter
        selectrum-highlight-candidates-function #'orderless-highlight-matches)
  (savehist-mode 1)
  (selectrum-mode 1))
