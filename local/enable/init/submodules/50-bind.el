;;; 50-bind.el -*- lexical-binding: t; -*-

(setup (:elpaca bind
                :host github
                :repo "repelliuss/bind"
                :files (:defaults "extensions/bind-setup.el"))
  
  (:require bind-setup)
  (bind-setup-integrate :bind)
  (put :bind 'lisp-indent-function 0)

  (bind ~keymap-leader
        "o" ~keymap-open
        "t" ~keymap-toggle
        "p" ~keymap-project
        "w" ~keymap-window
        "b" ~keymap-buffer
        "f" ~keymap-file
        "s" ~keymap-search
        "t" ~keymap-toggle
        "e" ~keymap-edit
        "TAB" ~keymap-workspace
        "q" ~keymap-quit)
  
  (defun ~bind-local (&optional key &rest bindings)
    (declare (indent 1))
    (if (and (eq (type-of key) (type-of (car bindings))))
        (apply #'bind-prefix (~key-make-local-prefix key) bindings)
      (apply #'bind-prefix (~key-make-local-prefix) (cons key bindings)))))


