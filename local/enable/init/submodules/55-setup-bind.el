(require 'setup)
(require 'bind)

(defun bind--insertable-setup-formp (form)
  "Returns symbol NO, YES, YES-MERGE for singular BIND form if a map from metadata can be insertable.
# in comments show where the map will be inserted."
  (cond
   ((bind--keyp (car form)) 'yes)	; (bind # ...)
   ((symbolp (car form)) 'no)		; (bind map ...)
   ((or (eq 'quote (caar form))
	(not (symbolp (caar form)))) (error (concat "Bad FORM given to SETUP :BIND. If (car FORM) "
						    "neither key or symbol, then (caar FORM) must "
						    "be equivalent to (SYMBOL ...).")))
   ((not (fboundp (caar form))) 'yes-merge) ; (bind (# map) ...)
   ((string-prefix-p "bind-" (symbol-name (caar form))) 'yes) ; (bind # (bind-* ...) ...)
   (t 'no)))				; (bind (function ...) ...)

(setup-define :bind
  (lambda (&rest form)
    `(bind--with-metadata (:main-file ,(symbol-name (setup-get 'feature)))
       ,(let ((map (setup-get 'map)))
	  (if (bind--singularp form)
	      (pcase (bind--insertable-setup-formp form)
		('no `(bind ,@form))
		('yes `(bind ,map ,@form))
		('yes-merge `(bind (,map ,@(car form))
				   ,@(cdr form))))
	    (pcase (bind--insertable-setup-formp (car form))
	      ('no `(bind ,@form))
	      ('yes `(bind (,map ,@(car form))
			   ,@(cdr form)))
	      ('yes-merge `(bind ((,map ,@(caar form))
				  ,@(cdar form))
				 ,@(cdr form))))))))
  :indent 1
  :documentation "Bind BINDINGS in current map if FORM lets and intents to inserting current map."
  :debug '(form sexp))

(provide 'setup-bind)
