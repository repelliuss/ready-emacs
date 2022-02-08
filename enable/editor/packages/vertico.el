;;; vertico.el -*- lexical-binding: t; -*-

(use-package vertico
  :init
  (setq vertico-cycle t
        vertico-scroll-margin 3)

  (vertico-mode 1)

  :extend (ace-window)
  (general-def vertico-map
    "M-w" #'ace-window)
  
  :extend (meow)
  (general-def vertico-map
    "M-j" #'vertico-next
    "M-k" #'vertico-previous
    "M-J" #'vertico-next-group
    "M-K" #'vertico-previous-group
    "M->" #'vertico-scroll-up
    "M-<" #'vertico-scroll-down
    "C->" #'vertico-last
    "C-<" #'vertico-first
    "<backspace>" #'backward-kill-word
    "M-<backspace>" #'meow-kill-whole-line
    "M-p" #'vertico-clipboard-save
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
   "M-S" #'vertico-quick-jump
   "M-s" #'vertico-quick-exit))

(use-package vertico-repeat
  :straight (:host github :repo "minad/vertico"
             :files ("extensions/vertico-repeat.el")
             :local-repo "vertico-repeat")
  :after (vertico)
  :general
  ("M-r" #'vertico-repeat)

  :attach (meow)
  (meow-leader-define-key
   '("r". vertico-repeat))

  :init
  (add-hook 'minibuffer-setup-hook #'vertico-repeat-save))


