;;; project.el -*- lexical-binding: t; -*-

(setup project
  (:elpaca nil)
  (bind ~keymap-normal
        "$" #'~project-aware-shell-command
        "&" #'~project-aware-async-shell-command)
  (:set project-list-file (concat ~dir-cache "project"))
  (set-keymap-parent ~keymap-project project-prefix-map)

  (:after-feature which-key
    (:set (prepend which-key-replacement-alist) '(("p$" . "prefix") . (nil . "project"))))

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


  (:after-feature enable-sub-fd
    (:with-function project--files-in-directory
      (:advice :override #'~project--files-in-directory-using-fd))

    (defun ~project--files-in-directory-using-fd (dir ignores &optional files)
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
                              (~fd-ignore-arguments ignores "./"))))
        (project--remote-file-names
         (sort (split-string (shell-command-to-string command) "\0" t)
               #'string<))))))




