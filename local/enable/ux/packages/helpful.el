;;; helpful.el -*- lexical-binding: t; -*-

(use-package helpful
  :init
  (bind
   (help-map
    [remap describe-function] #'helpful-callable
    [remap describe-key] #'helpful-key
    [remap describe-variable] #'helpful-variable)
   (help-map
    "." #'helpful-at-point))

  (advice-add #'describe-function :override #'helpful-callable)
  (advice-add #'describe-key :override #'helpful-key)
  (advice-add #'describe-variable :override #'helpful-variable)
  
  :config
  (bind helpful-mode-map
	"<" #'scroll-down-command
	">" #'scroll-up-command))

