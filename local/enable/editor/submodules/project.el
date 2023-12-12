;;; project.el -*- lexical-binding: t; -*-

(setq project-list-file (concat ~dir-cache "project"))
(set-keymap-parent ~keymap-project project-prefix-map)

(bind ~keymap-normal
      "$" #'~project-aware-shell-command
      "&" #'~project-aware-async-shell-command)

(defun fd-ignore-arguments (ignores dir)
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

(defun project--files-in-directory (dir ignores &optional files)
  (require 'find-dired)
  (require 'xref)
  (defvar find-name-arg)
  (let* ((default-directory dir)
         ;; Make sure ~/ etc. in local directory name is
         ;; expanded and not left for the shell command
         ;; to interpret.
         (localdir (file-local-name (expand-file-name dir)))
         (command (format "%s . %s %s --type f %s --print0 %s"
                          "fd"
                          ;; In case DIR is a symlink.
                          (file-name-as-directory localdir)
                          ""
                          (if files
                              (concat (shell-quote-argument "(")
                                      " " find-name-arg " "
                                      (mapconcat
                                       #'shell-quote-argument
                                       (split-string files)
                                       (concat " -o " find-name-arg " "))
                                      " "
                                      (shell-quote-argument ")"))
                            "")
                          (fd-ignore-arguments ignores "./"))))
    (project--remote-file-names
     (sort (split-string (shell-command-to-string command) "\0" t)
           #'string<))))

(defun ~project-aware-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-shell-command)
    (call-interactively #'shell-command)))

(defun ~project-aware-async-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-async-shell-command)
    (call-interactively #'async-shell-command)))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:set (prepend which-key-replacement-alist) '(("p$" . "prefix") . (nil . "project")))))
