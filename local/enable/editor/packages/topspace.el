;;; topspace.el -*- lexical-binding: t; -*-

;; TODO: use topspace from melpa

(use-package topspace
  :straight (:host github :repo "trevorpogue/topspace"
		   :files ("*.el"))
  :attach (dired)
  (add-hook 'dired-mode-hook #'topspace-mode)

  :init
  (setq-default topspace-active nil))
