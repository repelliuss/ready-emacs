;;; magit.el -*- lexical-binding: t; -*-

(setup transient)

(setup magit
  (:bind (~keymap-open
          (:autoload
	          "g" #'magit-status
	          "G" #'magit-dispatch))
         (prog-mode-map
          (~bind-local
              (:autoload
	              "g" #'magit-file-dispatch))))
  
  (:set magit-define-global-key-bindings nil
	    magit-revision-show-gravatars t)

  (:with-hook git-commit-mode-hook
    (:hook (defun ~meow-insert-at-eol ()
	         (when meow-mode
	           (end-of-line)
	           (meow-insert))))))
