;;; yasnippet.el -*- lexical-binding: t; -*-

(use-package yasnippet
  :demand t
  :config
  
  (setq yas-snippet-dirs (list (concat user-emacs-directory "yasnippet")))
  
  (yas-reload-all)
  
  (dolist (mode '(prog-mode-hook))
    (add-hook mode #'yas-minor-mode))

  :extend (meow)
  (add-hook 'yas-before-expand-snippet-hook #'meow-insert)
  (add-hook 'yas-after-exit-snippet-hook #'meow-insert-exit))

