;;; elisp.el -*- lexical-binding: t; -*-

(setup macrostep
  (:bind emacs-lisp-mode-map
	 (~bind-local
	     "e" #'macrostep-expand)))
