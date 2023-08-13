;;; 50-bind.el -*- lexical-binding: t; -*-

(setup (:elpaca bind
		:host github
		:repo "repelliuss/bind"
		:files (:defaults "extensions/bind-setup.el"))
  
  (:require bind-setup)
  (bind-setup-integrate :bind)
  (put :bind 'lisp-indent-function 0)
  
  (defun bind-local (&optional key &rest bindings)
    (declare (indent 1))
    (if (eq (stringp key) (stringp (car bindings)))
	(apply #'bind-prefix (@make-local-prefix key) bindings)
      (apply #'bind-prefix (@make-local-prefix) (cons key bindings)))))

