;;; nano-theme.el -*- lexical-binding: t; -*-

;; TODO: fork nano-theme
;; TODO: warn if enabled on init stage

(use-package nano-theme
  :straight (:host github
	     :repo "rougier/nano-theme")
  :init
  (dolist (command '(nano-mode nano-light nano-dark))
    (autoload command "nano-theme" nil 'interactive))
  
  (if (eq theme-preferred-background 'light)
      (load-theme 'nano-light 'no-confirm)
    (load-theme 'nano-dark 'no-confirm))

  :attach (rps/ui/theme)
  (setq theme-default-light 'nano-light
        theme-default-dark 'nano-dark))
