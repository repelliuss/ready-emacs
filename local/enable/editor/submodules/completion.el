;;; completion.el -*- lexical-binding: t; -*-

(setup-none
  (bind (:global-map)
        "M-/" #'dabbrev-completion
        "C-M-/" #'hippie-expand)
  (:set dabbrev-ignored-buffer-regexps '("\\.\\(?:pdf\\|jpe?g\\|png\\)\\'")
        tab-always-indent 'complete
        read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t))

