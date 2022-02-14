;;; orgmdb.el -*- lexical-binding: t; -*-

(use-package orgmdb
  :straight (:host github :repo "isamert/orgmdb.el")
  :attach (org-capture)
  (dolist (elt '(("l" "Log")
		 ("lw" "Watch" (rps-org-capture-log #'rps-orgmdb-capture "watch.org" "Title: "))))
    (add-to-list 'rps-org-capture-templates elt))
  
  :init
  (autoload #'rps-orgmdb-capture "orgmdb")
  
  :config
  (defun rps-orgmdb-capture (entry)
    (interactive)
    (let* ((category (completing-read "Category: "
                                      '("Movies" "Animes" "Series")
                                      nil t))
           (type (pcase category
                   ("Movies" 'movie)
                   ((or "Animes" "Series") 'series))))
      (goto-char (org-find-exact-headline-in-buffer category))
      (outline-next-heading)
      (save-excursion
        (orgmdb-movie-properties :title entry :type type)
        (goto-char (point-min))
        (org-cut-subtree)
        (kill-buffer))
      (org-paste-subtree))))
