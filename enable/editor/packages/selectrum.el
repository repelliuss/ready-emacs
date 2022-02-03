;;; selectrum.el -*- lexical-binding: t; -*-

(use-package selectrum
  :init
  (selectrum-mode 1)

  :config
  (setq selectrum-fix-vertical-window-height 10)

  :extend (orderless)
  (setq orderless-skip-highlighting (lambda () selectrum-is-active)
        selectrum-refine-candidates-function #'orderless-filter
        selectrum-highlight-candidates-function #'orderless-highlight-matches)

  :extend (meow)
  (general-def selectrum-minibuffer-map
    "M-j" #'selectrum-next-candidate
    "M-k" #'selectrum-previous-candidate
    "M->" #'selectrum-next-page
    "M-<" #'selectrum-previous-page
    "C->" #'selectrum-goto-end
    "C-<" #'selectrum-goto-beginning
    "M-s" #'selectrum-quick-select
    "<backspace>" #'selectrum-backward-kill-sexp
    "M-<backspace>" #'meow-kill-whole-line
    "M-w" #'meow-save
    "M-y" #'meow-yank
    "M-Y" #'yank-pop
    "M-RET" #'selectrum-submit-exact-input)

  (general-def meow-leader-keymap
    "r" #'selectrum-repeat))

;; TODO: M-w should work as vertico
