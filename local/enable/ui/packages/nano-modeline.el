;;; nano-modeline.el -*- lexical-binding: t; -*-

;; (defcustom nano-modeline-position 'top
;;   "Position of modeline.
;; Use `customize' for immediate effect."
;;   :type '(choice (const top) (const bottom))
;;   :set (lambda (sym val)
;;          (set-default sym val)
;;          (nano-modeline-mode 1))
;;   :group 'nano-modeline)

(@setup (:elpaca nano-modeline)
  (:option nano-modeline-prefix 'status)
  (nano-modeline-mode 1))
