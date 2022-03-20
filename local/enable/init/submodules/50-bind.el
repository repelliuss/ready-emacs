;;; bind.el -*- lexical-binding: t; -*-

;; TODO: add support for unbind
;; TODO: add support for repeat
;; TODO: support multiple-maps through map argument being list
(defun bind--done (keymaps bindings)
  (declare (indent 1))
  (bind--normalize bindings)
  (dolist (keymap keymaps)
    (while bindings
      (let ((key (car bindings))
	    (def (cadr bindings)))
	(define-key keymap (if (stringp key)
			       (kbd key)
			     key) def))
      (setq bindings (cddr bindings)))))

(defun bind--many (&rest rest)
  (dolist (elt rest)
    (let ((second (cadr elt)))
      (bind--done (car elt) (cdr elt)))))

(defmacro bind--listify (&rest rest)
  (let (unlisted)
    (dolist (elt rest)
      (setq unlisted (nconc unlisted `((list (list ,(car elt))
					     ,@(cdr elt))))))
    `(bind--many ,@unlisted)))

(defmacro bind--normalize (arg)
  `(if (consp (car ,arg))
       (setq ,arg (nconc (car ,arg) (cdr ,arg)))))

(defmacro bind (&rest rest)
  (let ((second (cadr rest)))
    (if (or (stringp second)
	    (vectorp second)
	    (fboundp (car second)))
	`(bind--done (list ,(car rest)) (list ,@(cdr rest)))
      `(bind--listify ,@rest))))

(defun bind-prefix (prefix &rest bindings)
  (declare (indent 1))
  (bind--normalize bindings)
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
  (bind--normalize bindings)
  (let ((it-bindings bindings))
    (while it-bindings
      (let ((def (cadr it-bindings)))
	(autoload def file nil t))
      (setq it-bindings (cddr it-bindings))))
  bindings)
