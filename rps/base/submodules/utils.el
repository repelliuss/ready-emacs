;;; utils.el -*- lexical-binding: t; -*-

(defmacro after! (file &rest body)
  `(eval-after-load ',file ',(macroexp-progn body)))
