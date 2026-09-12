;;; file-painter.el -*- lexical-binding: t; -*-

(defgroup file-painter nil
  "Insert file snippets for newly created files."
  :group 'convenience
  :prefix "file-painter-")

(defcustom file-painter-excluded-modes nil
  "Modes where file-painter should not insert snippets."
  :type '(repeat symbol))

(defcustom file-painter-default-name "file"
  "Default snippet name when no rule matches."
  :type 'string)

(defcustom file-painter-rules nil
  "Rules alist.
Each element:
(MODE-OR-MODES . MATCHER)

MODE-OR-MODES:
MODE || (MODE)

MATCHER:
NAME || PREDy || (PREDy)

PREDy:
(NAME) || (NAME . PRED)"
  :type 'sexp)

(defcustom file-painter-finder nil
  "Function to find a snippet by name. Takes a snippet name, returns snippet or nil."
  :type '(choice (const nil) function))

(defcustom file-painter-expander nil
  "Function to expand a snippet. Takes the snippet returned by `file-painter-finder'."
  :type '(choice (const nil) function))

(defcustom file-painter-operator-hook nil
  "Hook to use for triggering file-painter insertion.
If nil, `after-change-major-mode-hook' is used."
  :type '(choice (const nil) symbol))

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
  (add-hook (or file-painter-operator-hook
		'after-change-major-mode-hook)
	    (defun file-painter--inserting ()
	      (unless (eq major-mode 'fundamental-mode)
		(unless (memq major-mode file-painter-excluded-modes)
		  (file-painter-insert))
		(remove-hook (or file-painter-operator-hook
				 'after-change-major-mode-hook)
			     #'file-painter--inserting)))))

;;;###autoload
(defun file-painter-insert ()
  (interactive)
  (if-let* ((snippet
	    (or (funcall file-painter-finder file-painter-default-name)
		    (funcall file-painter-finder (file-painter--get-snippet-name
					                      (file-painter--get-rule))))))
      (funcall file-painter-expander snippet)))

;;;###autoload
(define-minor-mode file-painter-global-mode
  "Insert file snippet for newly created files"
  :lighter " file-painter"
  :global t
  (if file-painter-global-mode
      (add-hook 'find-file-not-found-functions #'file-painter--try-insert)
    (remove-hook 'find-file-not-found-functions #'file-painter--try-insert)))

(provide 'file-painter)
