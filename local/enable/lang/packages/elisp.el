;;; elisp.el -*- lexical-binding: t; -*-

(setup macrostep
  (:bind emacs-lisp-mode-map
         (~bind-local
             "m" #'macrostep-expand
             "e" #'pp-eval-last-sexp)))
