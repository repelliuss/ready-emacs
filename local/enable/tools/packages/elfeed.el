;;; elfeed.el -*- lexical-binding: t; -*-

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

(use-package elfeed
  :init
  (bind rps/open-map
	"E" #'elfeed)

  :config
  (bind elfeed-search-mode-map
        "s" #'rps-elfeed-search-tag-filter
        "S" #'elfeed-search-live-filter)

  (setq elfeed-search-title-max-width 100
        elfeed-search-title-min-width 30
        elfeed-search-trailing-width 25
        elfeed-search-filter "@2-week-ago -hide ")

  (add-hook 'elfeed-search-mode-hook #'elfeed-update)

  (dolist (hook '(elfeed-search-mode-hook elfeed-show-mode-hook))
    (add-hook hook (lambda () (setq-local browse-url-browser-function #'eww-browse-url))))

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
    (elfeed-search-update--force)))

(use-package elfeed-org
  :attach (elfeed)
  (elfeed-org)
  (setq rmh-elfeed-org-files nil)
  (dolist (file '("elfeed.org" "elfeed.org.gpg"))
    (setq file (expand-file-name (concat org-directory file)))
    (when (file-exists-p file)
      (add-to-list 'rmh-elfeed-org-files file))))

(use-package elfeed-web)
