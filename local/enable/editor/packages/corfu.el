;;; corfu.el -*- lexical-binding: t; -*-

(setup corfu
  (:set corfu-cycle t                   ; Enable cycling for `corfu-next/previous'
        corfu-scroll-margin 5           ; Use scroll margin
        corfu-quit-at-boundary nil
        corfu-quit-no-match nil
        corfu-on-exact-match nil
        corfu-right-margin-width 2
        corfu-left-margin-width 2)

  (global-corfu-mode 1)
  
  (:bind (corfu-map
	  "SPC" #'corfu-insert-separator
	  "M-j" #'corfu-next
	  "M-k" #'corfu-previous
	  "C-<" #'corfu-first
	  "C->" #'corfu-last 
	  "M-<" #'corfu-scroll-down
	  "M->" #'corfu-scroll-up))

  (:with-hook minibuffer-setup-hook
    (:hook (defun ~corfu-enable-always-in-minibuffer ()
             "Enable Corfu in the minibuffer if Vertico/Mct are not active."
             (unless (or (bound-and-true-p mct--active)
                         (bound-and-true-p vertico--input)
                         (eq (current-local-map) read-passwd-map))
               (corfu-mode 1))))))

(setup (:elpaca corfu-history
                :host github
                :repo "minad/corfu"
                :files ("extensions/corfu-history.el"))
  
  (:after-feature savehist
    (:set (prepend savehist-additional-variables) 'corfu-history))

  (corfu-history-mode 1))

(setup (:elpaca corfu-quick
                :host github
                :repo "minad/corfu"
                :files ("extensions/corfu-quick.el"))
  (:after-feature corfu
    (:bind corfu-map
	   "M-a" #'corfu-quick-insert
	   "M-A" #'corfu-quick-complete)))

(setup (:elpaca corfu-info
                :host github
                :repo "minad/corfu"
                :files ("extensions/corfu-info.el")))

(setup (:elpaca corfu-popupinfo
                :host github
                :repo "minad/corfu"
                :files ("extensions/corfu-popupinfo.el"))
  (:require corfu-popupinfo)
  (:set corfu-popupinfo-delay '(1.0 . 0.5))
  (:bind corfu-popupinfo-map
         ;; [remap corfu-first] #'corfu-popupinfo-beginning
         ;; [remap corfu-last] #'corfu-popupinfo-end
         ;; [remap corfu-scroll-down] #'corfu-popupinfo-scroll-down
         ;; [remap corfu-scroll-up] #'corfu-popupinfo-scroll-up
         "C-M-<" #'scroll-other-window-down
         "C-M->" #'scroll-other-window)
  (corfu-popupinfo-mode 1))

(setup cape
  (:bind (~keymap-completion
	   "t" #'complete-tag
	   "d" #'cape-dabbrev
	   "f" #'cape-file
	   "k" #'cape-keyword
	   "s" #'cape-symbol
	   "a" #'cape-abbrev
	   "i" #'cape-ispell
	   "l" #'cape-line
	   "w" #'cape-dict
	   "\\" #'cape-tex
	   "&" #'cape-sgml
	   "r" #'cape-rfc1345)
         ((:global-map)
          "M-c" ~keymap-completion)))
