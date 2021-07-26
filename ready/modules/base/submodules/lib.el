;;; lib.el -*- lexical-binding: t; -*-

(defmacro after! (file &rest body)
  `(with-eval-after-load ',file ,@body))
