;;; vertico.el -*- lexical-binding: t; -*-

;; FIX_UPSTREAM: elpaca sometimes fails to rebuild symlinks in builds/ after cache clear and reinstall
(cfg-pkg vertico
  (:opt vertico-cycle t
        vertico-scroll-margin 3
        vertico-count 15)

  (vertico-mode 1)

  (:bind (vertico-map
          (:prefix "M-"
            "j" #'vertico-next
            "k" #'vertico-previous
            "J" #'vertico-next-group
            "K" #'vertico-previous-group
            ">" #'vertico-scroll-up
            "<" #'vertico-scroll-down
            "Y" #'yank-pop
            "RET" #'vertico-exit-input
            "A" #'vertico-quick-jump
            "a" #'vertico-quick-exit)
          (:prefix "C-"
            ">" #'vertico-last
            "<" #'vertico-first))
         (rps-keymap-leader
          "r" #'vertico-repeat))

  (:hook-to 'minibuffer-setup-hook
    #'vertico-repeat-save)

  (:after ace-window
    (:bind vertico-map "M-w" #'ace-window))

  (:after meow
    (:bind vertico-map
           (:prefix "M-"
             "<backspace>" #'meow-kill-whole-line
             "y" #'meow-yank))))

