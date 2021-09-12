;;; core.el -*- lexical-binding: t; -*-

(defmacro after! (feature &rest body)
  `(eval-after-load ',feature (lambda () ,@body)))

(defvar rdy--finalize-hook)
