;;; vertico-consult-completion-in-region.el -*- lexical-binding: t; -*-

(setup-none
  (:after-feature vertico
    (:after-feature consult
      (:option completion-in-region-function (defun $vertico--consult-completion-in-region (&rest args)
					       (apply (if vertico-mode
							  #'consult-completion-in-region
							#'completion--in-region)
						      args))))))
