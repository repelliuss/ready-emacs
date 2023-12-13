;;; eshell.el -*- lexical-binding: t; -*-

(setup eshell
  (:elpaca nil)
  (:set eshell-prompt-function
        (defun ~eshell-prompt-function-just-last-directory ()
          (concat (car (last (split-string (eshell/pwd) "/"))) " $ "))))
