;;; file-painter.el -*- lexical-binding: t; -*-

;; TODO: defcustomize defvars

(defvar file-painter-excluded-modes nil)

(defvar file-painter-default-name "file")

(defcustom file-painter-rules nil
  "Rules alist.
Each element:
(MODE-OR-MODES . MATCHER)

MODE-OR-MODES:
MODE || (MODE)

MATCHER:
NAME || PREDy || (PREDy)

PREDy:
(NAME) || (NAME . PRED)")

(defvar file-painter-finder nil)
(defvar file-painter-expander nil)
(defvar file-painter-operator-hook nil)

(defun file-painter--get-rule ()
  (let (found
	(cur file-painter-rules))
    (while (and cur (not found))
      (let ((mode-or-modes (caar cur)))
	(if (or (eq major-mode mode-or-modes)
		(and (listp mode-or-modes) (memq major-mode mode-or-modes)))
	    (setq found (cdar cur))))
      (setq cur (cdr cur)))
    found))

(defun file-painter--get-snippet-name (preds)
  (let ((cur preds))
    (cond
     ((stringp cur) cur)
     ((stringp (cdr cur)) (if (string-match-p (cdr cur) buffer-file-name)
			      (car cur)))
     (t (let (found)
	  (while (and cur (not found))
	    (let ((snippet (caar cur))
		  (pred (cdar cur)))
	      (if (or (null pred)
		      (string-match-p pred buffer-file-name))
		  (setq found snippet)))
	    (setq cur (cdr cur)))
	  found)))))

(defun file-painter--try-insert ()
  (unless (memq major-mode file-painter-excluded-modes)
    (if file-painter-operator-hook
	(add-hook file-painter-operator-hook
		  (defun file-painter--inserting ()
		    (file-painter-insert)
		    (remove-hook file-painter-operator-hook
				 #'file-painter--inserting)))
      (file-painter-insert))))

;;;###autoload
(defun file-painter-insert ()
  (interactive)
  (if-let ((snippet (funcall file-painter-finder file-painter-default-name)))
      (funcall file-painter-expander snippet)
    (funcall file-painter-expander
	     (funcall file-painter-finder
		      (file-painter--get-snippet-name
		       (file-painter--get-rule))))))

;;;###autoload
(define-minor-mode file-painter-mode
  "Insert file snippet for newly created files"
  :lighter " file-painter"
  :global t
  (if file-painter-mode
      (add-hook 'find-file-not-found-functions #'file-painter--try-insert)
    (remove-hook 'find-file-not-found-functions #'file-painter--try-insert)))

(provide 'file-painter)
