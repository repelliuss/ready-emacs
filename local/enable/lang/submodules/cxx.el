;;; c-pp.el -*- lexical-binding: t; -*-

(setup cc-mode
  (:bind (c-mode-map c++-mode-map)
	 "<tab>" #'~c-indent-then-complete)

  (defun ~c-indent-then-complete ()
    (interactive)
    (if (= 0 (c-indent-line-or-region))
	(completion-at-point))))

