;;; nano-modeline.el -*- lexical-binding: t; -*-

(use-package nano-modeline
  :init
  (setq nano-modeline-position 'bottom)
  (nano-modeline-mode 1)

  (defcustom nano-modeline-position 'top
    "Position of modeline.
Use `customize' for immediate effect."
    :type '(choice (const top) (const bottom))
    :set (lambda (sym val)
           (set-default sym val)
           (nano-modeline-mode 1))
    :group 'nano-modeline))
