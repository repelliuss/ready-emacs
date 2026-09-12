;;; tab-bar.el -*- lexical-binding: t; -*-

(cfg tab-bar
  (:bind rps-keymap-workspace
         "TAB" #'rps-tab-smart-switch
         "u" #'tab-undo
         "n" #'tab-new-to
         "d" #'tab-close
         "r" #'tab-rename
         "g" #'tab-group
         "m" #'tab-move-to
         "p" #'project-other-tab-command
         "D" #'tab-close-other)

  (:opt tab-bar-show 1
        tab-bar-close-button-show nil
        tab-bar-auto-width nil)
  (:remove tab-bar-format #'tab-bar-format-add-tab)
  (:prepend tab-bar-tab-name-format-functions #'rps-tab-name-upcase-and-variable-pitch-name))

(cfg-pkg tabgo)

(defun rps-tab-smart-switch ()
  (interactive)
  (call-interactively
   (if (< 2 (length (tab-bar-tabs)))
       (if (fboundp #'tabgo) #'tabgo #'tab-switch)
     #'tab-next)))

(defun rps-tab-name-upcase-and-variable-pitch-name (name _tab _i)
  (add-face-text-property
   0 (length name) 'variable-pitch t name)
  (concat
   "    "
   (upcase name)
   "    "))
