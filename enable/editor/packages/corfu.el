;;; corfu.el -*- lexical-binding: t; -*-

(use-package corfu
  :general
  (corfu-map
   "M-j" #'corfu-next
   "M-k" #'corfu-previous
   "C-<" #'corfu-first
   "C->" #'corfu-last
   "M-<" #'corfu-scroll-down
   "M->" #'corfu-scroll-up)

  ;; Optional customizations
  :custom
  (corfu-cycle t)         ;; Enable cycling for `corfu-next/previous'
  (corfu-scroll-margin 5) ;; Use scroll margin

  :init
  (corfu-global-mode))

;; Use dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand)))
