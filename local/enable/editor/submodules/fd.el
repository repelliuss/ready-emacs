;;; fd.el -*- lexical-binding: t; -*-

(setup-none
  (defvar ~fd-common-args '("-i"
                            "-H"
                            "-E .git"))
  (when ~os-windows-p
    (:set (append ~fd-common-args) "--path-separator=/")))

(setup consult
  (:elpaca nil)
  (:after-feature consult
    (:set (append* consult-fd-args) ~fd-common-args)))

(defun ~fd-ignore-arguments (ignores dir)
    "Convert IGNORES and DIR to a list of arguments for `find'.
IGNORES is a list of glob patterns.  DIR is an absolute
directory, used as the root of the ignore globs."
    (cl-assert (not (string-match-p "\\`~" dir)))
    (if (not ignores)
        ""
      ;; TODO: All in-tree callers are passing in just "." or "./".
      ;; We can simplify.
      ;; And, if we ever end up deleting xref-matches-in-directory, move
      ;; this function to the project package.
      (setq dir (file-name-as-directory dir))
      (concat
       " -E "
       (mapconcat
        (lambda (ignore)
          (when (string-match-p "/\\'" ignore)
            (setq ignore (concat ignore "*")))
          (shell-quote-argument (if (string-match "\\`\\./" ignore)
                                    (replace-match dir t t ignore)
                                  (if (string-prefix-p "*" ignore)
                                      ignore
                                    (concat "*/" ignore)))))
        ignores
        " -E ")
       " --prune")))




