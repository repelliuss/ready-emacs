;;; 50-bind.el -*- lexical-binding: t; -*-

(cfg-pkg (:elpaca bind
                  :host github
                  :repo "repelliuss/bind"
                  :branch "finalizer"
                  :files (:defaults "extensions/bind-cfg.el"))

  (:require bind-cfg bind)

  (bind-cfg-integrate :bind)

  (bind rps-keymap-leader
        "o" (cons "open" rps-keymap-open)
        "p" (cons "project" rps-keymap-project)
        "w" (cons "window" rps-keymap-window)
        "b" (cons "buffer" rps-keymap-buffer)
        "f" (cons "file" rps-keymap-file)
        "s" (cons "search" rps-keymap-search)
        "t" (cons "toggle" rps-keymap-toggle)
        "e" (cons "edit" rps-keymap-edit)
        "n" (cons "note" rps-keymap-note)
        "TAB" (cons "workspace" rps-keymap-workspace)
        "q" (cons "quit" rps-keymap-quit)
        "RET" #'bookmark-jump)

  (defun bind-make-local-prefix (&optional key)
    (concat rps-key-leader-prefix " " rps-key-local-leader-prefix (if key " ") key))

  (defun bind-locally (&optional key &rest args)
    (declare (indent 1))
    (if (and (eq (type-of key) (type-of (car args))))
        (apply #'bind-prefix (bind-make-local-prefix key) args)
      (apply #'bind-prefix (bind-make-local-prefix) key args))))

