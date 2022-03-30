;;; bind.el -*- lexical-binding: t; -*-

;; TODO: add support for unbind
;; TODO: add support for repeat
;; TODO: support multiple-maps through map argument being list

(defmacro bind--normalize-bindings (arg)
  `(if (consp (car ,arg))
       (setq ,arg (nconc (car ,arg) (cdr ,arg)))))

(defun bind--bind (keymap bindings)
  (while bindings
    (let ((key (car bindings))
	  (def (cadr bindings)))
      (define-key keymap (if (stringp key)
			     (kbd key)
			   key) def))
    (setq bindings (cddr bindings))))

(defun bind--done (keymap-s bindings)
  (declare (indent 0))
  (bind--normalize-bindings bindings)
  (if (keymapp keymap-s)
      (bind--bind keymap-s bindings)
    (dolist (keymap keymap-s)
      (bind--bind keymap bindings))))

(defmacro bind--many (&rest rest)
  (let (unlisted)
    (dolist (elt rest)
      (setq unlisted (nconc unlisted
			    `((cons (bind--normalize-first ,(car elt))
				    (list ,@(cdr elt)))))))
    `(dolist (elt (list ,@unlisted))
       (bind--done (car elt) (cdr elt)))))

(defmacro bind--normalize-first (map-s-or-fn)
  (if (or (fboundp (car-safe map-s-or-fn))
	  (symbolp map-s-or-fn))
      map-s-or-fn
    `(list ,@map-s-or-fn)))

(defmacro bind (&rest rest)
  (let ((first (car rest))
	(second (cadr rest)))
    (if (or (stringp second)
	    (vectorp second)
	    (fboundp (car second)))
	`(bind--done (bind--normalize-first ,first)
		     (list ,@(cdr rest)))
      `(bind--many ,@rest))))

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

(defun bind-command (file &rest bindings)
  (declare (indent 1))
  (bind--normalize-bindings bindings)
  (let ((it-bindings bindings))
    (while it-bindings
      (let ((def (cadr it-bindings)))
	(autoload def file nil t))
      (setq it-bindings (cddr it-bindings))))
  bindings)
