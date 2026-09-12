;;; org-roam.el -*- lexical-binding: t; -*-
(cfg-pkg org-roam
  (:bind
    (rps-keymap-note
     (:prefix "r"
       "l" #'org-roam-buffer-toggle
       "f" #'org-roam-node-find
       "i" #'org-roam-node-insert
       "c" #'org-roam-capture)
     (:prefix "j"
       "c" #'org-roam-dailies-capture-today
       "t" #'org-roam-dailies-goto-today
       "b" #'org-roam-dailies-capture-yesterday
       "y" #'org-roam-dailies-goto-yesterday
       "f" #'org-roam-dailies-capture-date
       "d" #'org-roam-dailies-goto-date
       "p" #'org-roam-dailies-goto-previous-note
       "n" #'org-roam-dailies-goto-next-note)))
  (:after (enable-event :file "local" "org")
    (:opt org-roam-directory (:mkdir org-directory "roam")))
  (:opt
   org-roam-db-location (:join rps-dir-cache "org-roam" "org-roam.db")
   org-roam-dailies-directory "journal/"
   org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (:mkdir rps-dir-cache "org-roam")
  (:prepend display-buffer-alist '("\\*org-roam\\*"
                                    (display-buffer-in-direction)
                                    (direction . right)
                                    (window-width . 0.33)
                                    (window-height . fit-window-to-buffer)))
  (:opt org-roam-capture-templates `(("n" "note" plain "%?"
                                 :if-new (file+head "note/${slug}.org"
                                                    ,(concat "#+title: ${title}\n"
                                                             "#+date: %<%FT%T%z>\n"))
                                 :unnarrowed t
                                 :empty-lines 1))
   org-roam-capture-ref-templates `(("r" "ref" plain "\n%?\n\n${body}" :target
					                 (file+head "note/${slug}.org" ,(concat "#+title: ${title}\n"
									                                        "#+date: %<%FT%T%z>"))
					                 :unnarrowed t)))


  (:after-this
    (:prepend org-roam-mode-sections #'org-roam-unlinked-references-section))

  (:after (enable-event :file "local" "org")
    (org-roam-db-autosync-mode 1))

  )

(cfg-pkg org-roam-ui
  (:bind rps-keymap-note
         (:prefix "r"
           "g" #'org-roam-ui-mode
           (:prefix "u"
             "z" #'org-roam-ui-node-zoom
             "l" #'org-roam-ui-node-local)))
  (:opt org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))
