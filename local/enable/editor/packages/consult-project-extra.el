;;; consult-project-extra.el -*- lexical-binding: t; -*-

;; BUG: pulls in project and project pulls in xref and I think it is a
;; bug to autoload define-key bindings because if this is loaded after
;; user configurations, they may override the user bindings. which did
;; mine for embark, so I load consult before embark
(setup consult-project-extra
  (:with-function consult-project-extra--file
    (:advice :before (defun ~tab-set-name-for-project (project-root)
		       (tab-new-to)
		       (tab-rename
			(file-name-nondirectory
			 (string-trim-right project-root "/"))))))
  
  (:after-feature enable-sub-project
    (:bind ~keymap-leader
	   "p" #'consult-project-extra-find
	   "P" project-prefix-map)))
