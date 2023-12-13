;;; presentation.el -*- lexical-binding: t; -*-

(setup presentation
  (:bind ~keymap-toggle
	 "f" #'text-scale-mode
	 "F" #'global-text-scale-mode)
  (:alias global-text-scale-mode #'presentation-mode)
  (:set presentation-default-text-scale 3
        text-scale-mode-amount 3))
