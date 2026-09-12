;;; elfeed.el -*- lexical-binding: t; -*-

(defun rps-elfeed-db-compact-when-idle ()
  (run-with-idle-timer 60 nil
                       (lambda ()
                         (message "Compacting Elfeed database...")
                         (let ((inhibit-message t))
                           (elfeed-db-compact)))))

(cfg-pkg elfeed
  (:after 'org
    (:bind rps-keymap-open "E" #'elfeed)
    (:after-this
      (:bind elfeed-search-mode-map
             "s" #'rps-elfeed-search-tag-filter
             "S" #'elfeed-search-live-filter))

    (:opt elfeed-search-title-max-width 100
          elfeed-search-title-min-width 30
          elfeed-search-trailing-width 25
          elfeed-search-filter "@2-week-ago -hide "
          rps-elfeed-directory (:join org-directory "elfeed")
          elfeed-db-directory (:join-d rps-elfeed-directory "database"))
    (:mkdir rps-elfeed-directory)

    (:hook-transient elfeed-db-update-hook #'rps-elfeed-db-compact-when-idle)

    (:hook-to 'elfeed-search-mode #'elfeed-update)))

(store-install "mpv"
  :skip '(:system android)
  :then
  (lambda ()
    (cfg-pkg emms
      (:opt emms-player-list (list 'emms-player-mpv))
      (:advice-to #'elfeed-show-play-enclosure :before
        (defun rps-elfeed-load-emms (&rest _)
          (require 'emms-setup)
          (emms-all))))))

(cfg-pkg elfeed-org
  (:after elfeed
    (:opt rmh-elfeed-org-files (cl-loop for file in '("elfeed.org" "elfeed.org.gpg")
                                        for abs-file = (expand-file-name file rps-elfeed-directory)
                                        when (file-exists-p abs-file)
                                        collect abs-file))
    (elfeed-org)))

(cfg-pkg elfeed-score
  (:after elfeed
    (:after-this
      (:bind elfeed-search-mode-map "=" elfeed-score-map))
    (:opt elfeed-score-serde-score-file (:join rps-elfeed-directory "elfeed-score" "elfeed.score")
          elfeed-score-rule-stats-file (:join rps-elfeed-directory "elfeed-score" "elfeed.stats")
          elfeed-search-print-entry-function #'elfeed-score-print-entry)
    (:mkdir rps-elfeed-directory "elfeed-score")
    (:touch elfeed-score-serde-score-file)
    (elfeed-score-enable)))

(defun rps-elfeed-search-tag-filter ()
  "Filter Elfeed search buffer by tags using completion.
Completion accepts multiple including and excluding tags
and also arbitrary input."
  (interactive)
  (unwind-protect
      (let* ((elfeed-search-filter-active :live)
             (db-tags (elfeed-db-get-all-tags))
             (plus-tags (mapcar (lambda (tag)
                                  (format "+%s" tag))
                                db-tags))
             (minus-tags (mapcar (lambda (tag)
                                   (format "-%s" tag))
                                 db-tags))
             (all-tags (append plus-tags minus-tags))
	         (crm-separator " ")
             (tags (completing-read-multiple
                    "Apply one or more tags: "
                    all-tags))
             (input (string-join `(,@tags) " ")))
        (setq elfeed-search-filter input))
    (elfeed-search-update :force)))

(defun rps-elfeed-db-remove-entry (id)
  "Removes the entry for ID"
  (avl-tree-delete elfeed-db-index id)
  (remhash id elfeed-db-entries))

(defun rps-elfeed-search-remove-selected ()
  "Remove selected entries from database"
  (interactive)
  (let* ((entries (elfeed-search-selected))
         (count (length entries)))
    (when (y-or-n-p (format "Delete %d entires?" count))
      (cl-loop for entry in entries
               do (rps-elfeed-db-remove-entry (elfeed-entry-id entry)))))
  (elfeed-search-update--force))
