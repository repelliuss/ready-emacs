;;; vc-plastic.el -*- lexical-binding: t; -*-

;; (defun vc-plastic-registered (file)
;;   "Check whether FILE is registered with Plastic."
;;   (let ((dir (vc-git-root file)))
;;     (when dir
;;       (with-temp-buffer
;;         (let* (process-file-side-effects
;;                ;; Do not use the `file-name-directory' here: git-ls-files
;;                ;; sometimes fails to return the correct status for relative
;;                ;; path specs.
;;                ;; See also: https://marc.info/?l=git&m=125787684318129&w=2
;;                (name (file-relative-name file dir))
;;                (str (with-demoted-errors "Error: %S"
;;                       (cd dir)
;;                       (vc-git--out-ok "ls-files" "-c" "-z" "--" name)
;;                       ;; If result is empty, use ls-tree to check for deleted
;;                       ;; file.
;;                       (when (eq (point-min) (point-max))
;;                         (vc-git--out-ok "ls-tree" "--name-only" "-z" "HEAD"
;;                                         "--" name))
;;                       (buffer-string))))
;;           (and str
;;                (> (length str) (length name))
;;                (string= (substring str 0 (1+ (length name)))
;;                         (concat name "\0"))))))))

(defun vc-plastic-registered (file)
  "Check whether FILE is registered with Plastic."
  nil)

;; (pop vc-handled-backends)
;; (add-to-list 'vc-handled-backends 'Plastic)
