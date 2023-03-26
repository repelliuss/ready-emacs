;;; bind.el -*- lexical-binding: t; -*-

;; TODO: add header info
;; TODO: check linter
;; TODO: add docstrings
;; TODO: add examples
;; TODO: rest to form
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

(defun bind-foreach-key-def (bindings function)
  (declare (indent 1))
  (while bindings
    (funcall function (car bindings) (cadr bindings))
    (setq bindings (cddr bindings))))

(defun bind--flatten1-key-of-bindings (bindings)
  (let (new-bindings)
    (bind-foreach-key-def bindings
      (lambda (key def)
	(if (not (consp key))
	    (setq new-bindings (nconc new-bindings (list key def)))
	  (setq new-bindings (nconc new-bindings key))
	  (if (consp def)
	      (setq new-bindings (nconc new-bindings def))))))
    new-bindings))

(defun bind--bind (keymap bindings)
  (bind-foreach-key-def bindings
    (lambda (key def)
      (funcall bind--definer
	       keymap
	       (if (stringp key) (kbd key) key)
	       def))))

(defun bind--done (keymap-s bindings)
  (setq bindings (bind--flatten1-key-of-bindings bindings))
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
  (setq bindings (bind--flatten1-key-of-bindings bindings))
  (let (new-bindings
	(prefix (concat prefix " ")))
    (bind-foreach-key-def bindings
      (lambda (key def)
	(push def new-bindings)
	(push (concat prefix key) new-bindings)))
    new-bindings))

(defun bind-autoload (&optional file-as-symbol &rest bindings)
  (declare (indent 1))
  (let (file)
    (if (symbolp file-as-symbol)
	(setq file (symbol-name file-as-symbol))
      (setq file (plist-get bind--metadata :main-file)
	    bindings `(,file-as-symbol ,@bindings)))
    (if (not file) (error "Bad FILE-AS-SYMBOL argument to BIND-AUTOLOAD."))    
    (setq bindings (bind--flatten1-key-of-bindings bindings))
    (bind-foreach-key-def bindings
      (lambda (key def)
	(autoload def file nil t))))
  bindings)

(defun bind-repeat (&rest bindings)
  (declare (indent 0))
  (setq bindings (bind--flatten1-key-of-bindings bindings))
  (let ((main-keymap (plist-get bind--metadata :main-keymap)))
    (if (keymapp (symbol-value main-keymap))
	(bind-foreach-key-def bindings
	  (lambda (key def)
	    (put def 'repeat-map main-keymap)))
      (display-warning 'bind-repeat
		       (format "Couldn't repeat bindings: %s. No main keymap given." bindings))))
  bindings)

(provide 'bind)

