;;; workspace.el -*- lexical-binding: t; -*-

(bind ~keymap-workspace
      "TAB" #'~tab-smart-switch
      "." #'find-file-other-tab
      "," #'switch-to-buffer-other-tab
      "j" #'tab-next
      "k" #'tab-previous
      "u" #'tab-undo
      "n" #'tab-new-to
      "N" #'tab-duplicate
      "d" #'tab-close
      "r" #'tab-rename
      "g" #'tab-group
      "m" #'tab-move-to
      "p" #'project-other-tab-command
      "D" #'tab-close-other)

(defun ~tab-smart-switch ()
  (interactive)
  (call-interactively
   (if (< 2 (length (tab-bar-tabs)))
       #'tab-switch
     #'tab-next)))

