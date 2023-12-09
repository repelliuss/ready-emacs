;;; vertico.el -*- lexical-binding: t; -*-

(setup (:elpaca vertico
                :host github
                :repo "minad/vertico"
                :files (:defaults (:exclude "extensions/*")))
  (vertico-mode 1)
  
  (:bind vertico-map
         (:prefix "M-"
           "j" #'vertico-next
           "k" #'vertico-previous
           "J" #'vertico-next-group
           "K" #'vertico-previous-group
           ">" #'vertico-scroll-up
           "<" #'vertico-scroll-down
           "Y" #'yank-pop
           "RET" #'vertico-exit-input)
         (:prefix "C-"
           ">" #'vertico-last
           "<" #'vertico-first))
  
  (:set vertico-cycle t
        vertico-scroll-margin 3)

  (:with-feature ace-window
    (:when-loaded
      (:bind vertico-map "M-w" #'ace-window)))

  (:with-feature meow
    (:when-loaded
      (:bind vertico-map
             (:prefix "M-"
               "<backspace>" #'meow-kill-whole-line
               "y" #'meow-yank)))))

(setup (:elpaca vertico-quick
                :host github
                :repo "minad/vertico"
                :files ("extensions/vertico-quick.el"))
  (:with-feature vertico
    (:when-loaded
      (:bind vertico-map
             "M-A" #'vertico-quick-jump
             "M-a" #'vertico-quick-exit))))

(setup (:elpaca vertico-repeat
                :host github
                :repo "minad/vertico"
                :files ("extensions/vertico-repeat.el"))
  (:bind ~keymap-leader
         "r" #'vertico-repeat)

  (:with-hook minibuffer-setup-hook
    (:hook #'vertico-repeat-save)))


