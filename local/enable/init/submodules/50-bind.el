;;; bind.el --- Bind commands to keys -*- lexical-binding: t; -*-

;; Copyright (C) 2023 repelliuss

;; Author: repelliuss <https://github.com/repelliuss>
;; Maintainer: repelliuss <repelliuss@gmail.com>
;; Created: March 26, 2023
;; Modified: March 26, 2023
;; Version: 0.9.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience
;; Homepage: https://github.com/repelliuss/bind

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; TODO: commentary.

;;; Code:

;; TODO: check linter
;; TODO: add docstrings
;; TODO: add examples

(defgroup bind nil
  "Bind many keys to many keymaps with ease."
  :group 'emacs
  :prefix "bind-"
  :package-version '(Bind . "0.9.0"))

(defcustom bind--metadata nil
  "A plist that carries the info of upper `bind' forms to lower `bind' forms.
This is so that binding transformer functions don't make user
type the same information again.  For example `bind-autoload' can
guess the file function to be autoloaded if not explicitly
given.

This variable will usually be populated lexically, though one can
provide and make use of persistant data."
  :type '(plist))

(defcustom bind--definer #'define-key
  "A function that decides what to do with keymap, key and def.
See `define-key' for what keymap, key and def is.

This is the function called at the end of very things after all
of the things are resolved. For example it can define the key or
unbind it such as `bind--definer-unbind'."
  :type 'function)

(defun bind--definer-unbind (keymap key def)
  "Unbind KEY from KEYMAP and DEF from KEYMAP if DEF is actually a key."
  (define-key keymap key nil)
  (if (bind-keyp def)
      (define-key keymap def nil)))

(defun bind--definer-local (keymap key def))

(defun bind--mappings-in-keymap (keymap bindings)
  "Define each key def mapping in BINDINGS to KEYMAP."
  (bind-foreach-key-def bindings
    (lambda (key def)
      (funcall bind--definer
	       keymap
	       (if (stringp key) (kbd key) key)
	       def))))

(defun bind--mappings-foreach-keymap (keymap-s bindings)
  "Define each key def mappings in one or more KEYMAP-S.
This function will be called after each binding transformer calls
so BINDINGS need to be flattened."
  (setq bindings (bind-flatten1-key-of-bindings bindings))
  (if (keymapp keymap-s)
      (bind--mappings-in-keymap keymap-s bindings)
    (dolist (keymap keymap-s)
      (bind--mappings-in-keymap keymap bindings))))

(defmacro bind--singular (form)
  `(bind-with-metadata (:main-keymap (bind--main-keymap ',(car form)))
     (bind--mappings-foreach-keymap ,(car form) (list ,@(cdr form)))))

(defmacro bind--multiple (form-prefix forms)
  "Bind multiple `bind' FORMS."
  (let (singular-binds)
    (dolist (form forms)
      (setq singular-binds (nconc singular-binds `((,@form-prefix ,form)))))
    (macroexp-progn singular-binds)))

(defmacro bind--main-keymap (bind-first)
  "Extract main keymap from BIND-FIRST argument of `bind' form.
Main keymap is the keymap given to bind form or first of the given keymaps."
  `(cond
    ((or (symbolp ,bind-first) (fboundp (car ,bind-first))) ,bind-first)
    (t (car ,bind-first))))		; list of keymaps

(defun bind--singularp (form)
  "t if `bind' FORM doesn't contain multiple `bind' forms."
  (let ((second (cadr form)))
    (or (bind-keyp second)
	(and (symbolp (car second)) (fboundp (car second))))))

(defun bind-keyp (exp)
  "t if EXP is a valid key for `define-key'."
  (or (stringp exp) (vectorp exp)))

(defun bind-foreach-key-def (bindings function)
  "Call FUNCTION for each key def mappings in BINDINGS.
FUNCTION is a function that takes key and def as arguments."
  (declare (indent 1))
  (while bindings
    (funcall function (car bindings) (cadr bindings))
    (setq bindings (cddr bindings))))

(defun bind-flatten1-key-of-bindings (bindings)
  "Flatten each first level key definition in BINDINGS.
A binding transformer function will return list of new
bindings. A function that works on BINDINGS (such as another
transformer function) and one that probably uses
`bind-foreach-key-def' expects bindings to be in the form of (KEY
DEF...). This function can be used to merge list of new bindings
and return the expected form."
  (let (new-bindings)
    (bind-foreach-key-def bindings
      (lambda (key def)
	(if (not (consp key))
	    (setq new-bindings (nconc new-bindings (list key def)))
	  (setq new-bindings (nconc new-bindings key))
	  (if (consp def)
	      (setq new-bindings (nconc new-bindings def))))))
    new-bindings))

(defmacro bind-with-metadata (plist &rest body)
  "Evaluate BODY with PLIST merged with `bind--metadata'."
  (declare (indent 1))
  `(let* ((bind--metadata (append (list ,@plist) bind--metadata)))
     ,@body))

(defun bind-global-map ()
  (current-global-map))

(defun bind-local-map ()
  (or (current-local-map)
      (let ((local-map (make-sparse-keymap)))
	(use-local-map local-map)
	local-map)))

(defmacro bind (&rest form)
  (if (bind--singularp form)
      `(bind--singular ,form)
    `(bind--multiple (bind--singular) ,form)))

(defmacro bind-undo (&rest form)
  "Undo (or unbind) `bind' form keys."
  `(let ((bind--definer #'bind--definer-unbind))
     (bind ,@form)))

(defun bind-prefix (prefix &rest bindings)
  (declare (indent 1))
  (setq bindings (bind-flatten1-key-of-bindings bindings))
  (let (new-bindings
	(prefix (concat prefix " ")))
    (bind-foreach-key-def bindings
      (lambda (key def)
	(push def new-bindings)
	(push (concat prefix key) new-bindings)))
    new-bindings))

(defun bind-autoload (&optional file-as-symbol-or-key &rest bindings)
  (declare (indent 1))
  (let (file)
    (if (symbolp file-as-symbol-or-key)
	(setq file (symbol-name file-as-symbol-or-key))
      (setq file (plist-get bind--metadata :main-file)
	    bindings `(,file-as-symbol-or-key ,@bindings)))
    (if (not file) (error "Bad FILE-AS-SYMBOL-OR-KEY argument to BIND-AUTOLOAD."))    
    (setq bindings (bind-flatten1-key-of-bindings bindings))
    (bind-foreach-key-def bindings
      (lambda (key def)
	(autoload def file nil t))))
  bindings)

(defun bind-repeat (&rest bindings)
  (declare (indent 0))
  (setq bindings (bind-flatten1-key-of-bindings bindings))
  (let ((main-keymap (plist-get bind--metadata :main-keymap)))
    (if (keymapp (symbol-value main-keymap))
	(bind-foreach-key-def bindings
	  (lambda (key def)
	    (put def 'repeat-map main-keymap)))
      (display-warning 'bind-repeat
		       (format "Couldn't repeat bindings: %s. No main keymap given." bindings))))
  bindings)

(provide 'bind)

;;; bind.el ends here
