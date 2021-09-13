;;; core.el -*- lexical-binding: t; -*-

(require 'cl-lib)

(defmacro after! (feature &rest body)
  `(eval-after-load ',feature (lambda () ,@body)))

(cl-defmacro bind-keys! (&rest args &key map prefix prefix-map
				  prefix-docstring menu-name
				  filter &allow-other-keys)
  (bind-keys
    :map map
    :prefix prefix
    :prefix-map prefix-map
    :prefix-docstring prefix-docstring
    :menu-name menu-name
    :filter filter
    (seq-filter (lambda (binding)
		    (not (memq (car binding)
			       '(:map :prefix :prefix-map
				      :prefix-docstring :menu-name
				      :filter))))
		  (cl-loop for (key bind) on args by #'cddr
			   collect `(,key . ,bind)))))

(defvar rdy--finalize-hook)
