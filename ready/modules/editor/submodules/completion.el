;;; completion.el -*- lexical-binding: t; -*-

(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t
      completion-cycle-threshold 3)

(setq tab-always-indent 'complete
      c-tab-always-indent 'complete)

(provide 'ready/editor/completion)
