;;; vertico.el -*- lexical-binding: t; -*-

(use-package vertico
  :init
  (setq vertico-cycle t
        vertico-scroll-margin 3)

  (vertico-mode 1)

  :extend (ace-window)
  (bind vertico-map
	"M-w" #'ace-window)
  
  :extend (meow)
  (bind vertico-map
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
	"M-y" #'meow-yank
	"M-Y" #'yank-pop
	"M-RET" #'vertico-exit-input))

(use-package vertico-quick
  :straight (:local-repo "vertico/extensions")
  :after (vertico)
  :init
  (bind vertico-map
	"M-A" #'vertico-quick-jump
	"M-a" #'vertico-quick-exit))

(use-package vertico-repeat
  :straight (:local-repo "vertico/extensions")
  :after (vertico)
  :attach (meow)
  (bind rps/leader-map
	(bind-autoload 'vertico
	  "r" #'vertico-repeat))
  
  :init
  (bind (current-global-map)
	(bind-autoload 'vertico
	  "M-r" #'vertico-repeat))

  (add-hook 'minibuffer-setup-hook #'vertico-repeat-save))


