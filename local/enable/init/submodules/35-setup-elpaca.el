(require 'setup)
(require 'elpaca)

(defun setup--elpaca-shorthand (sexp)
  (let ((recipe (cadr sexp)))
    (if (consp recipe)
        (car recipe)
      recipe)))

(setup-define :elpaca
  (lambda (_) 'elpaca)
  :documentation "Install RECIPE with `straight-use-package'.
This macro can be used as HEAD, and will replace itself with the
first RECIPE's package."
  :shorthand #'setup--elpaca-shorthand)

(defun @setup--elpaca-find-recipe (lst)
  (let (recipe)
    (while (and lst (not recipe))
      (if (and (consp (car lst))
	       (eq (caar lst) :elpaca))
	  (setq recipe (cadar lst)))
      (setq lst (cdr lst)))
    recipe))

(defmacro @setup (name &rest body)
  (declare (indent 1))
  (if (and (consp name)
	   (eq :elpaca (car name)))
      `(elpaca ,(cadr name)
	 (setup ,(setup--elpaca-shorthand name)
	   ,@body))
    (if-let ((recipe (or (@setup--elpaca-find-recipe (cdr name))
			 (@setup--elpaca-find-recipe body))))
	`(setup ,name
	   (elpaca ,recipe
	     (setup ,(if (consp name)
			 (let ((shorthand (get (car name) 'setup-shorthand)))
			   (and shorthand (funcall shorthand name)))
		       name)
	       ,@body)))
      `(setup ,name ,@body))))

