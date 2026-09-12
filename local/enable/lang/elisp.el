;;; elisp.el -*- lexical-binding: t; -*-

(cfg-pkg macrostep
  (:bind emacs-lisp-mode-map
         (:locally
          "m" #'macrostep-expand
          "e" #'pp-eval-last-sexp
          "b" #'eval-buffer
          "d" #'eval-defun)))

