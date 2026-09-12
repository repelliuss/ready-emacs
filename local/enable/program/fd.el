;;; fd.el -*- lexical-binding: t; -*-

(cfg emacs
  (defvar rps-fd-common-args '("-i"
                               "-H"
                               "-E .git"))
  (when rps-system-windows-p
    (:append rps-fd-common-args "--path-separator=/"))

  (:after consult
    (:append* consult-fd-args rps-fd-common-args)))

(store-install "fd")

(defun rps-fd-ignore-arguments (ignores dir)
  "Convert IGNORES to fd -E arguments.
IGNORES is a list of glob patterns.  DIR is the root directory."
  (if (not ignores)
      ""
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
