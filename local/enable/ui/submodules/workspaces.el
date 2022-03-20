;;; workspaces.el -*- lexical-binding: t; -*-

(bind
 (rps/leader-map
  "<tab>" (setq rps/workspace-map (make-sparse-keymap)))
 (rps/workspace-map
  "<tab>" #'tab-smart-switch
  "." #'find-file-other-tab
  "," #'switch-to-buffer-other-tab
  "j" #'tab-next
  "k" #'tab-previous
  "u" #'tab-undo
  "n" #'tab-duplicate
  "N" #'tab-new-to
  "d" #'tab-close
  "r" #'tab-rename
  "g" #'tab-group
  "m" #'tab-move-to
  "p" #'project-other-tab-command
  "D" #'tab-close-other))

(defun tab-smart-switch ()
  (interactive)
  (call-interactively
   (if (< 1 (length (cl-remove-duplicates (tab-bar-tabs)
					  :key #'cdadr)))
       #'tab-switch
     #'tab-next)))
