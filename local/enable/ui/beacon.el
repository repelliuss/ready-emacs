;;; beacon.el -*- lexical-binding: t; -*-

;; alternative is hl-line-flash

;; NOTE: beacon-fast is a candidate for upstreaming to beacon package

(cfg-pkg beacon
  (:opt beacon-blink-when-buffer-changes nil
        beacon-blink-when-window-changes nil
        beacon-blink-when-scroll-invoked t
        beacon-blink-when-frame-regain-focus nil
        beacon-blink-duration 0.1)
  (:after beacon-fast
    (global-beacon-fast-mode 1)
    (:advice-to '(backward-paragraph forward-paragraph) :after
      #'beacon--blink-n)))

(defcustom beacon-blink-when-frame-regain-focus nil
  "Blink when Emacs regain focus.")

(defun beacon--blink-on-regain-focus ()
  "Blink if `beacon-blink-when-focused' is non-nil and Emacs regain focus."
  (when (and beacon-blink-when-focused (frame-focus-state))
    (beacon--blink-n)))

(defun beacon--blink-n (&rest _)
  (unless (or (not beacon-fast-mode)
              (run-hook-with-args-until-success 'beacon-dont-blink-predicates)
              (memq (or this-command last-command) beacon-dont-blink-commands))
    (beacon-blink)))

(defun beacon-fast-mode-turn-on ()
  (beacon-fast-mode 1))

(defun beacon-fast-mode-release ()
  (interactive)
  (advice-remove #'scroll-up-command #'beacon--blink-n)
  (advice-remove #'scroll-down-command #'beacon--blink-n)
  (remove-function after-focus-change-function #'beacon--blink-on-regain-focus)
  (remove-hook 'window-buffer-change-functions #'beacon--blink-n 'local)
  (remove-hook 'window-selection-change-functions #'beacon--blink-n 'local))

(define-minor-mode beacon-fast-mode
  "A faster version of beacon that don't mess with CPU resources."
  :lighter beacon-lighter
  (require 'beacon)
  (if beacon-fast-mode
      (progn
        (when beacon-blink-when-buffer-changes
          (add-hook 'window-buffer-change-functions #'beacon--blink-n nil 'local))
        (when beacon-blink-when-window-changes
          (add-hook 'window-selection-change-functions #'beacon--blink-n nil 'local))
        (when beacon-blink-when-scroll-invoked
          (advice-add #'scroll-up-command :after #'beacon--blink-n)
          (advice-add #'scroll-down-command :after #'beacon--blink-n))
        (when beacon-blink-when-frame-regain-focus
          (add-function :after after-focus-change-function #'beacon--blink-on-regain-focus)))
    (remove-hook 'window-buffer-change-functions #'beacon--blink-n 'local)
    (remove-hook 'window-selection-change-functions #'beacon--blink-n 'local)))

(define-globalized-minor-mode global-beacon-fast-mode
  beacon-fast-mode beacon-fast-mode-turn-on
  (unless global-beacon-fast-mode
    (advice-remove #'scroll-up-command #'beacon--blink-n)
    (advice-remove #'scroll-down-command #'beacon--blink-n)
    (remove-function after-focus-change-function #'beacon--blink-on-regain-focus)))

(provide 'beacon-fast)
