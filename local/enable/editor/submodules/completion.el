;;; completion.el -*- lexical-binding: t; -*-

(bind esc-map
      "c" (setq rps/completion-map (make-sparse-keymap))
      "C" #'completion-at-point)

(setq completion-map (make-sparse-keymap))

(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t
      completion-cycle-threshold 2)

(setq tab-always-indent 'complete
      c-tab-always-indent 'complete)

(bind (current-global-map)
      "M-/" #'hippie-expand)

(provide 'rps/editor/completion)
