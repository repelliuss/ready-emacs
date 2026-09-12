;;; doom-modeline.el -*- lexical-binding: t; -*-

(cfg-pkg doom-modeline
  (:opt doom-modeline-indent-info t
        doom-modeline-height (+ (window-font-height nil 'mode-line) 16)
        doom-modeline-buffer-file-name-style 'file-name)
  (doom-modeline-mode 1))

(cfg emacs
  (:opt display-time-day-and-date nil)
  (size-indication-mode 1)
  (line-number-mode -1))
