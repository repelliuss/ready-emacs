;;; vertico.el -*- lexical-binding: t; -*-

(use-package vertico
  :init
  (setq vertico-cycle t
        vertico-scroll-margin 0)

  (savehist-mode 1)
  (vertico-mode 1)

  :extend (meow)
  (general-def
    :keymaps 'vertico-map
    "M-j" #'vertico-next
    "M-k" #'vertico-previous
    "M-J" #'vertico-next-group
    "M-K" #'vertico-previous-group
    "M->" #'vertico-scroll-up
    "M-<" #'vertico-scroll-down
    "C->" #'vertico-last
    "C-<" #'vertico-first
    ;; "M-s" #'selectrum-quick-select
    "<backspace>" #'backward-kill-sexp
    "M-<backspace>" #'meow-kill-whole-line
    "M-w" #'vertico-clipboard-save
    "M-y" #'meow-clipboard-yank
    "M-Y" #'yank-pop
    "M-RET" #'vertico-exit-input)

  (defun vertico-clipboard-save ()
    (interactive)
    (clipboard-kill-ring-save (- (point-max) (length (car vertico--input))) (point-max))))

(use-package vertico-quick
  :straight (:host github :repo "minad/vertico"
             :files ("extensions/vertico-quick.el")
             :local-repo "vertico-quick")
  :after (vertico)
  :general
  (vertico-map
   "C-q" #'vertico-quick-insert
   "M-q" #'vertico-quick-exit)

  :init
  ;; TODO: pending feat/extend
  (with-eval-after-load 'meow
    (general-def
      :keymaps 'vertico-map
      "M-s" #'vertico-quick-jump)))

(use-package vertico-repeat
  :straight (:host github :repo "minad/vertico"
             :files ("extensions/vertico-repeat.el")
             :local-repo "vertico-repeat")
  :after (vertico)
  :general
  ("M-r" #'vertico-repeat)

  :init
  (add-hook 'minibuffer-setup-hook #'vertico-repeat-save)

  ;; TODO: pending feat/extend
  (with-eval-after-load 'meow
    (general-def
      :keymaps 'meow-leader-keymap
      "r" #'vertico-repeat)))

;; TODO: move savehist-mode to a submodule, also from selectrum
;; TODO: make :straight keyword no-op when backend is not straight
;; TODO: consult enhancements
;; TODO: check doom's switch buffer
