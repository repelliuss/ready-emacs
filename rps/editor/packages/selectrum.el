;;; selectrum.el -*- lexical-binding: t; -*-

(use-package selectrum
  :demand
  :bind (:map selectrum-minibuffer-map
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
  (after! meow
    (bind-keys :map meow-leader-keymap
               ("r" . selectrum-repeat)))
  (after! orderless
    (setq orderless-skip-highlighting (lambda () selectrum-is-active)
          selectrum-refine-candidates-function #'orderless-filter
          selectrum-highlight-candidates-function #'orderless-highlight-matches))
  (savehist-mode 1)
  (selectrum-mode 1))
