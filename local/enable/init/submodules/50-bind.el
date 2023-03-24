;;; bind.el -*- lexical-binding: t; -*-

;; TODO: add header info
;; TODO: check linter
;; TODO: add docstrings
;; TODO: add examples
;; TODO: rest to form
;; TODO: undef should recursively unbind all keys
;; TODO: refactor (bind--done ,(car form) (list ,@(cdr form))) expr
;; TODO: add bind definer

(defvar bind--definer #'define-key)

(defvar bind--metadata nil)

(defun bind--keyp (exp)
  (or (stringp exp) (vectorp exp)))

(defun bind--undefine-key (keymap key def)
  (define-key keymap key nil)
  (if (bind--keyp def)
      (define-key keymap def nil)))

(defmacro bind--normalize-bindings (arg)
  `(setq ,arg (flatten-list ,arg)))

(defun bind--bind (keymap bindings)
  (while bindings
    (let ((key (car bindings))
	  (def (cadr bindings)))
      (funcall bind--definer
	       keymap (if (stringp key)
			  (kbd key)
			key) def))
    (setq bindings (cddr bindings))))

(defun bind--done (keymap-s bindings)
  (bind--normalize-bindings bindings)
  (if (keymapp keymap-s)
      (bind--bind keymap-s bindings)
    (dolist (keymap keymap-s)
      (bind--bind keymap bindings))))

(defmacro bind--many (&rest rest)
  (let (bindings)
    (dolist (elt rest)
      (setq bindings
	    (nconc bindings
		   `((bind ,@elt)))))
    (macroexp-progn bindings)))

(defmacro bind--main-keymap (bind-first)
  `(cond
    ((or (symbolp ,bind-first) (fboundp (car ,bind-first))) ,bind-first)
    (t (car ,bind-first))))		; list of maps

;; TODO: better metadata merge
(defmacro bind--with-metadata (plist &rest body)
  (declare (indent 1))
  `(let* ((bind--metadata (append (list ,@plist) bind--metadata)))
     ,@body))

(defun bind--singularp (form)
  (let ((second (cadr form)))
    (or (stringp second)
	(vectorp second)
	(and (symbolp (car second)) (fboundp (car second))))))

(defmacro bind (&rest form)
  (if (bind--singularp form)
      `(bind--with-metadata (:main-keymap (bind--main-keymap ',(car form)))
	 (bind--done ,(car form) (list ,@(cdr form))))
    `(bind--many ,@form)))

(defmacro unbind (&rest rest)
  `(let ((bind--definer #'bind--undefine-key))
     (bind ,@rest)))

(defun bind-prefix (prefix &rest bindings)
  (declare (indent 1))
  (bind--normalize-bindings bindings)
  (let (new-bindings
	(prefix (concat prefix " ")))
    (while bindings
      (let ((key (car bindings))
	    (def (cadr bindings)))
	(push def new-bindings)
	(push (concat prefix key) new-bindings))
      (setq bindings (cddr bindings)))
    new-bindings))

(defun bind-autoload (&optional file-as-symbol &rest bindings)
  (declare (indent 1))
  (let (file)
    (if (symbolp file-as-symbol)
	(setq file (symbol-name file-as-symbol))
      (setq file (plist-get bind--metadata :main-file)
	    bindings `(,file-as-symbol ,@bindings)))
    (if (not file) (error "Bad FILE-AS-SYMBOL argument to BIND-AUTOLOAD."))    
    (bind--normalize-bindings bindings)
    (let ((it-bindings bindings))
      (while it-bindings
	(let ((def (cadr it-bindings)))
	  (autoload def file nil t))
	(setq it-bindings (cddr it-bindings)))))
  bindings)

(defun bind-repeat (&rest bindings)
  (declare (indent 0))
  (bind--normalize-bindings bindings)
  (let ((main-keymap (plist-get bind--metadata :main-keymap))
	(it-bindings bindings))
    (if (keymapp (symbol-value main-keymap))
	(while it-bindings
	  (let ((def (cadr it-bindings)))
	    (put def 'repeat-map main-keymap))
	  (setq it-bindings (cddr it-bindings)))
      (display-warning 'bind-repeat
		       (format "Couldn't repeat bindings: %s. No main keymap given." bindings))))
  bindings)

(provide 'bind)

