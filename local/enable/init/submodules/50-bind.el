;;; bind.el -*- lexical-binding: t; -*-

;; TODO: add header info
;; TODO: check linter
;; TODO: add docstrings
;; TODO: add examples
;; TODO: use flatten instead of bind normalize and flatten first arg if not keymap in case there is a function that returns multiple keymaps instead of one like setq

(defvar bind--definer #'define-key)

(defvar bind--metadata nil)

(defun bind--undefine-key (keymap key def)
  (define-key keymap key nil)
  (if (or (stringp def)
	  (vectorp def))
      (define-key keymap def nil)))

(defmacro bind--normalize-bindings (arg)
  `(if (consp (car ,arg))
       (setq ,arg (nconc (car ,arg) (cdr ,arg)))))

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
		   `((bind--with-metadata ,elt)))))
    (macroexp-progn bindings)))

(defmacro bind--normalize-first (map-s-or-fn)
  (if (or (fboundp (car-safe map-s-or-fn))
	  (symbolp map-s-or-fn))
      map-s-or-fn
    `(list ,@map-s-or-fn)))

(defmacro bind--main-keymap (bind-first)
  `(cond
    ((or (symbolp ,bind-first) (fboundp (car ,bind-first))) ,bind-first)
    (t (car ,bind-first))))		; list of maps

;; TODO: better metadata merge
(defmacro bind--with-metadata (rest)
  (let ((first (car rest)))
    `(let* ((bind--metadata (append (list :main-keymap (bind--main-keymap ',first)) bind--metadata)))
       (bind--done (bind--normalize-first ,first)
		   (list ,@(cdr rest))))))

(defmacro bind (&rest rest)
  (let ((second (cadr rest)))
    (if (or (stringp second)
	    (vectorp second)
	    (fboundp (car second)))
	`(bind--with-metadata ,rest)
      `(bind--many ,@rest))))

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

;; TODO: better main file name
(defun bind-autoload (&optional file-as-symbol &rest bindings)
  (declare (indent 1))
  (let (file)
    (if (symbolp file-as-symbol)
	(setq file (symbol-name file-as-symbol))
      (setq file (plist-get bind--metadata :main-file)
	    bindings `(,file-as-symbol ,@bindings)))
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
