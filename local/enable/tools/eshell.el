;;; eshell.el -*- lexical-binding: t; -*-

(cfg eshell
  (:opt eshell-prompt-function (defun rps-eshell-prompt-function-just-last-directory ()
                                 (concat (car (last (split-string (eshell/pwd) "/"))) " $ "))
        eshell-aliases-file (concat rps-dir-local "eshell/alias")
        eshell-history-file-name (concat rps-dir-cache "eshell/history")
        eshell-last-dir-ring-file-name (concat rps-dir-cache "eshell/lastdir"))
  (:hook #'eshell-hist-mode)
  (:mkdir rps-dir-cache "eshell"))
