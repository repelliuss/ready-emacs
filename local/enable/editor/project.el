;;; project.el -*- lexical-binding: t; -*-

(defun rps-project--files-in-directory-using-fd (dir ignores &optional files)
  (require 'find-dired)
  (require 'xref)
  (defvar find-name-arg)
  (let* ((default-directory dir)
         (localdir (file-local-name (expand-file-name dir)))
         (command (format "%s . %s %s --type f %s --print0 %s %s"
                          "fd"
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
                          (rps-fd-ignore-arguments ignores "./")
                          (string-join rps-fd-common-args " "))))
    (project--remote-file-names
     (sort (split-string (shell-command-to-string command) "\0" t)
           #'string<))))

(defun rps-project-aware-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-shell-command)
    (call-interactively #'shell-command)))

(defun rps-project-aware-async-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-async-shell-command)
    (call-interactively #'async-shell-command)))

(cfg project
  (:bind rps-keymap-normal
         "$" #'rps-project-aware-shell-command
         "&" #'rps-project-aware-async-shell-command)
  (:opt project-list-file (concat rps-dir-cache "project"))
  (set-keymap-parent rps-keymap-project project-prefix-map)

  (:after enable-sub-fd
    (:advice-to #'project--files-in-directory :override
      #'rps-project--files-in-directory-using-fd)))

(cfg-pkg (:elpaca project-x
                    :host github
                    :repo "karthink/project-x")
  (:autoload project-x-try-local)
  (:after project
    (:opt project-x-local-identifier (list ".project" ".plastic" (lambda (dir) (file-expand-wildcards (concat dir "*.sln")))))
    (:append project-find-functions #'project-x-try-local)))
