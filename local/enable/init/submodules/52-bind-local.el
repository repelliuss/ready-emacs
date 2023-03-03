;;; bind-local.el -*- lexical-binding: t; -*-

(defun bind-local (&optional key &rest bindings)
  (declare (indent 1))
  (if (eq (stringp key) (stringp (car bindings)))
      (apply #'bind-prefix (@make-local-prefix key) bindings)
    (apply #'bind-prefix (@make-local-prefix) (cons key bindings))))
