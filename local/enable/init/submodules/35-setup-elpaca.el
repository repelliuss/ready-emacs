(require 'setup)
(require 'elpaca)

(defun setup--elpaca-shorthand (sexp)
  "Retrieve feature from SEXP of :elpaca macro."
  (let ((order (cadr sexp)))
    (if (consp order)
        (car order)
      order)))

(setup-define :elpaca
  (lambda (&rest _) t)
  :documentation "A placeholder SETUP macro that evaluates to t."
  :shorthand #'setup--elpaca-shorthand)

(defun setup--elpaca-find-order (lst)
  "Find :elpaca setup macro in LST and return ELPACA ORDER."
  (let (order)
    (while (and lst (not order))
      (if (and (consp (car lst))
	       (eq (caar lst) :elpaca))
	  (setq order (cdar lst)))
      (setq lst (cdr lst)))
    order))

(defmacro @setup (name &rest body)
  "Setup macro with :elpaca support."
  (declare (indent 1))
  (if (and (consp name)
	   (eq :elpaca (car name)))
      `(elpaca ,(cdr name)
	 (setup ,(setup--elpaca-shorthand name)
	   ,@body))
    (if-let ((order (or (and (consp name) (setup--elpaca-find-order (cdr name)))
			(setup--elpaca-find-order body))))
	`(setup ,name
	   (elpaca ,order
	     (setup ,(if (consp name)
			 (let ((shorthand (get (car name) 'setup-shorthand)))
			   (and shorthand (funcall shorthand name)))
		       name)
	       ,@body)))
      `(setup ,name ,@body))))
