(require 'setup)
(require 'elpaca)

(defun elpaca-setup--shorthand (sexp)
  "Retrieve feature from SEXP of :elpaca macro."
  (let ((order (cadr sexp)))
    (if (consp order)
        (car order)
      order)))

(defun elpaca-setup--find-order (lst)
  "Find :elpaca setup macro in LST and return ELPACA ORDER."
  (let (order)
    (while (and lst (not order))
      (if (and (consp (car lst))
	       (eq (caar lst) :elpaca))
	  (setq order (cdar lst)))
      (setq lst (cdr lst)))
    order))

(defun elpaca-setup--call-shorthand (name)
  (if (consp name)
      (let ((shorthand (get (car name) 'setup-shorthand)))
	(and shorthand (funcall shorthand name)))
    name))

(defmacro elpaca-setup--default-dependent-order-condition (use-elpaca-by-default name)
  (if use-elpaca-by-default
      `(or (and (consp ,name)
		(or (and (eq :elpaca (car ,name)) (cdr ,name))
		    (elpaca-setup--find-order ,name)))
	   (elpaca-setup--call-shorthand ,name))
    `(and (consp ,name)
	  (or (and (eq :elpaca (car ,name)) (cdr ,name))
	      (elpaca-setup--find-order ,name)))))

(defmacro elpaca-setup-integrate (use-elpaca-by-default)
  `(progn
     (fset 'elpaca-setup--setup-initial-definition (symbol-function #'setup))
     
     (setup-define :elpaca
       (lambda (&rest _) t)
       :documentation "A placeholder SETUP macro that evaluates to t."
       :shorthand #'elpaca-setup--shorthand)

     (defmacro setup (name &rest body)
       (declare (indent 1))
       (if-let ((order (or (elpaca-setup--find-order body)
			   (elpaca-setup--default-dependent-order-condition ,use-elpaca-by-default name))))
	   `(elpaca-setup--setup-initial-definition ,name
			       (elpaca ,order
				       (elpaca-setup--setup-initial-definition ,(if (consp order)
							       (car order)
							     order)
							  ,@body)))
	 `(elpaca-setup--setup-initial-definition ,name ,@body)))

     (put #'setup 'function-documentation (advice--make-docstring 'elpaca-setup--setup-initial-definition))))

(defun elpaca-setup-teardown ()
  (fset 'setup #'elpaca-setup--setup-initial-definition)
  (setq setup-macros (assoc-delete-all :elpaca setup-macros)))

(elpaca-setup-integrate t)
