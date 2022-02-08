;;; ace-window.el -*- lexical-binding: t; -*-

(use-package ace-window
  :commands (aw-flip-window)

  :config
  (setq aw-keys '(?q ?e ?r ?u ?i ?o)
        aw-scope 'frame)

  (set-face-attribute 'aw-leading-char-face nil
                      :foreground "white" :background "purple"
                      :weight 'bold :height 3.5))
