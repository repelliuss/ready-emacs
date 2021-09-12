;;; selectrum.el -*- lexical-binding: t; -*-

(use-package selectrum
  :demand t
  :general (:keymaps 'selectrum-minibuffer-map
            "M-j" #'selectrum-next-candidate
            "M-k" #'selectrum-previous-candidate
            "M-d" #'selectrum-next-page
            "M-u" #'selectrum-previous-page
            "M-s" #'selectrum-quick-select
            "M-c" #'selectrum-cycle-display-style
            "M-<backspace>" #'kill-whole-line
            "C-<backspace>" #'selectrum-backward-kill-sexp
            "M-w" #'kill-ring-save
            "M-y" #'yank-pop
            "M-RET" #'selectrum-submit-exact-input)
  :config
  (after! 'meow
    (general-def
      :keymaps 'meow-leader-keymap
      "r" #'selectrum-repeat
      [remap kill-whole-line] #'meow-kill-whole-line
      [remap kill-ring-save] #'meow-clipboard-save
      [remap yank-pop] #'meow-clipboard-yank))
  (after! 'orderless
    (setq orderless-skip-highlighting (lambda () selectrum-is-active)
          selectrum-refine-candidates-function #'orderless-filter
          selectrum-highlight-candidates-function #'orderless-highlight-matches))
  (savehist-mode)
  (selectrum-mode))
