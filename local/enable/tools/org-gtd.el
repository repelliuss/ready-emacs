;;; org-gtd.el -*- lexical-binding: t; -*-

;; NOTE: HOLD seems to be a reserved keyword?
;; NOTE: can't I specify multi todo keyword sequence? like per file? (no type but per file)
;; can't I rename inbox.org to stuff.org?
;; can't I rename ORG_GTD_CAPTURED_AT to CAPTURED_AT? I should rename gtd properties used.
;; I can't put ORG_GTD_REFILE to file level property
;; inbox and tasks file variables are const
;; org id to be uuid
;;
;; automatic refile target detection is bad
;;   "Get GTD-only refile targets for TYPE.
;; Only looks in `org-gtd-tasks.org', ignoring user's `org-refile-targets'
;; and other `org-agenda-files'.  This ensures auto-refile always goes to
;; the GTD file, regardless of user configuration."
;; org-gtd-reactivate on someday/maybe item didnt refile it back to actions
;; calendar items should be in todo state?
;; cancelling items archive filename in tmp file from process buffer
;; refiling to a file where NEXT is mapped to somth else still refiles as NEXT
;; which items are refiled as TODO
;; reflect-missed-items is not autoloaded
;; processing messes up window after each clarification
(cfg-pkg org-gtd
  (:bind rps-keymap-note
         (:autoload
             "c" #'org-gtd-capture
             "e" #'org-gtd-engage
             "p" #'org-gtd-process-inbox
             "n" #'org-gtd-show-all-next
             "s" #'org-gtd-reflect-stuck-projects))
  (:opt org-gtd-update-ack "4.0.0"
        org-gtd-keyword-mapping '((todo . "TODO")
                                  (next . "NEXT")
                                  (wait . "WAIT")
                                  (done . "DONE")
                                  (canceled . "CNCL"))
        org-gtd-save-after-organize t
        org-gtd-clarify-display-helper-buffer t
        org-gtd-archive-location nil
        org-gtd-refile-to-any-target nil
        org-gtd-refile-prompt-for-types '(single-action project-heading project-task
                                                        calendar someday delegated
                                                        tickler habit
                                                        knowledge quick-action trash))
  (:safe-local 'org-gtd-keyword-mapping)
  (:advice-to #'org-gtd-id--generate :override #'org-id-new)
  
  (:after 'org
    (:opt org-gtd-directory (:mkdir org-directory "roam" "gtd")))
  
  (:after 'org-agenda
    (:prepend org-agenda-files org-gtd-directory))
  
  (cfg org-gtd-projects
    (:after-this
      (org-edna-mode 1)))
  (cfg org-gtd-clarify
    (:after-this
      (cfg org-gtd-organize
        (:autoload org-gtd-organize)
        (:bind org-gtd-clarify-mode-map
               "C-c c" #'org-gtd-organize))))
  (cfg org-gtd-areas-of-focus
    (:opt org-gtd-areas-of-focus '("Myself" "Home" "Health" "Family" "Career"))
    (:autoload #'org-gtd-set-area-of-focus)
    (:after org-gtd-organize-core
      (:hook-to 'org-gtd-organize-hooks #'org-gtd-set-area-of-focus)))
  (cfg org-agenda
    (:after-this
      (:bind "C-c ." #'org-gtd-agenda-transient))))
