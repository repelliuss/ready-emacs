;;; bind.el -*- lexical-binding: t; -*-

(defun bind--done (map bindings)
  (declare (indent 1))
  (print bindings)
  (bind--normalize bindings)
  (while bindings
      (let ((key (car bindings))
	    (def (cadr bindings)))
	(print (kbd key))
	(print def)
	(define-key map (kbd key) def))
      (setq bindings (cddr bindings))))

(defun bind--many (&rest rest)
  (dolist (elt rest)
    (let ((second (cadr elt)))
      (bind--done (car elt) (if (stringp second)
				(cdr elt)
			      second)))))

(defmacro bind--listify (&rest rest)
  (let (unlisted)
    (dolist (elt rest)
      (setq unlisted (nconc unlisted `((list ,@elt)))))
    `(bind--many ,@unlisted)))

(defmacro bind--normalize (arg)
  `(if (consp (car ,arg))
       (setq ,arg (nconc (car ,arg) (cdr ,arg)))))

(defmacro bind (&rest rest)
    "Foo.
REST can be in the following forms:

MAP BINDINGS
(MAP BINDINGS)...

MAP:
keymap

BINDINGS:
kbd-key-str function (ex: \"s\" #'save-buffer)

MAP-AND-BINDINGS:
list of (MAP BINDINGS)

BINDINGS can be prefixed using (bind-prefix BINDINGS) function."
  (let ((second (cadr rest)))
    (cond
     ((stringp second) `(bind--done ,(car rest) (list ,@(cdr rest))))
     ((fboundp (car second)) `(bind--done ,(car rest) ,second))
     (t `(bind--listify ,@rest)))))

(defun bind-prefix (prefix &rest bindings)
  (declare (indent 1))
  (bind--normalize bindings)
  (print bindings)
  (let (new-bindings
	(prefix (concat prefix " ")))
    (while bindings
      (let ((key (car bindings))
	    (def (cadr bindings)))
	(push def new-bindings)
	(push (concat prefix key) new-bindings))
      (setq bindings (cddr bindings)))
    new-bindings))

(defun bind-command (file &rest bindings)
  (declare (indent 1))
  (let ((it-bindings bindings))
    (while it-bindings
      (let ((def (cadr it-bindings)))
	(autoload def file nil t))
      (setq it-bindings (cddr it-bindings))))
  bindings)
