;;; magit.el -*- lexical-binding: t; -*-

(defun rps-meow-insert-at-eol ()
  (when meow-mode
    (end-of-line)
    (meow-insert)))

(cfg-pkg magit
  (:bind (rps-keymap-open
          (:autoload
	          "g" #'magit-status
	          "G" #'magit-dispatch))
         (prog-mode-map
          (:locally
           (:autoload
	           "g" #'magit-file-dispatch))))

  (:opt magit-define-global-key-bindings nil
	    magit-revision-show-gravatars t
        magit-commit-show-diff nil)

  (when rps-system-windows-p
    (:opt magit-status-sections-hook '(magit-insert-status-headers
                                       magit-insert-merge-log
                                       magit-insert-rebase-sequence
                                       magit-insert-am-sequence
                                       magit-insert-sequencer-sequence
                                       magit-insert-bisect-output
                                       magit-insert-bisect-rest
                                       magit-insert-bisect-log
                                       magit-insert-untracked-files
                                       magit-insert-unstaged-changes
                                       magit-insert-staged-changes
                                       magit-insert-stashes
                                       magit-insert-unpushed-to-pushremote
                                       magit-insert-unpushed-to-upstream-or-recent
                                       magit-insert-unpulled-from-pushremote
                                       magit-insert-unpulled-from-upstream)))

  (:hook-to 'git-commit-mode-hook #'rps-meow-insert-at-eol))

(cfg-pkg forge
  (:after magit
    (:require forge))
  (:opt forge-database-file (concat rps-dir-cache "forge/forge-database.sqlite"))
  (make-directory (file-name-directory forge-database-file) 'with-parents))
