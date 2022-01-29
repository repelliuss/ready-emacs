;;; fd.el -*- lexical-binding: t; -*-

(defvar consult-fd-args "fd --color=never --full-path -i -H -E .git --regex")

(defun consult--fd-builder (input)
  "Build command line given INPUT."
  (pcase-let* ((cmd (split-string-and-unquote consult-fd-args))
               (`(,arg . ,opts) (consult--command-split input))
               (`(,re . ,hl) (funcall consult--regexp-compiler arg 'extended)))
    (when re
      (list :command (append cmd
                             (list (consult--join-regexps re 'extended))
                             opts)
            :highlight hl))))

(autoload #'consult--directory-prompt "consult")
;;;###autoload
(defun consult-fd (&optional dir initial)
  "Search for regexp with find in DIR with INITIAL input.

The find process is started asynchronously, similar to `consult-grep'.
See `consult-grep' for more details regarding the asynchronous search."
  (interactive "P")
  (let* ((prompt-dir (consult--directory-prompt "Find" dir))
         (default-directory (cdr prompt-dir)))
    (find-file (consult--find (car prompt-dir) #'consult--fd-builder initial))))

(use-package consult
  :straight nil
  :after (rps/editor/search)
  :general
  (rps/search-map
   "s f" #'consult-fd))
