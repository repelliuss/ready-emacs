;;; project.el -*- lexical-binding: t; -*-

(setq project-list-file (concat ~dir-cache "project"))
(set-keymap-parent ~keymap-project project-prefix-map)

(bind ~keymap-normal
      "$" #'~project-aware-shell-command
      "&" #'~project-aware-async-shell-command)

(defun ~project-aware-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-shell-command)
    (call-interactively #'shell-command)))

(defun ~project-aware-async-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-async-shell-command)
    (call-interactively #'async-shell-command)))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("p$" . "prefix") . (nil . "project")))))
