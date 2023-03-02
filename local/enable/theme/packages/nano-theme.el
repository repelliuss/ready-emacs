;;; nano-theme.el -*- lexical-binding: t; -*-

;; TODO: fork nano-theme
;; TODO: warn if enabled on init stage

(use-package nano-theme
  :straight (:host github
	     :repo "rougier/nano-theme")
  :init
  (dolist (command '(nano-mode nano-light nano-dark))
    (autoload command "nano-theme" nil 'interactive))

  (@theme-load-if-preferred 'nano-theme 'nano-light 'nano-dark))
