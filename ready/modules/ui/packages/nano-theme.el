;;; nano-theme.el -*- lexical-binding: t; -*-

;; TODO: fork nano-theme
;; TODO: warn if enabled on init stage

(use-package nano-theme
  :straight (:host github
             :repo "rougier/nano-theme")
  :commands (nano-mode nano-light nano-dark)
  :init
  (nano-mode)
  (if (eq ready-theme-preferred-background 'light)
      (nano-light)
    (nano-dark)))
