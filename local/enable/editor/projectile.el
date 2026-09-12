;;; projectile.el -*- lexical-binding: t; -*-

(defun rps-tab-bar-projectile-kill-buffers (tab _last)
  (when (projectile-session--tab-root tab)
    (let ((default-directory (projectile-session--tab-root tab)))
      (projectile-kill-buffers))))

(cfg-pkg projectile
  (:opt projectile-indexing-method 'hybrid
        projectile-sort-order 'recently-active
        projectile-enable-caching t
        projectile-cache-file (:join rps-dir-cache "projectile/projectile.cache")
        projectile-known-projects-file (:join rps-dir-cache "projectile/projectile-bookmarks.eld")
        projectile-frecency-file (:join rps-dir-cache "projectile/projectile-frecency.eld")
        projectile-session-directory (:join-d rps-dir-cache "projectile/sessions")
        project-list-file (concat rps-dir-cache "project")
        projectile-session-autosave t
        projectile-auto-cleanup-known-projects t)

  ;; From projectile: In some shells on Windows, '/' is automatically expanded. Try to use '//' instead
  (when rps-system-mingw64-p
    (:after-this
      (:opt projectile-git-fd-args (concat projectile-git-fd-args " --path-separator=//")
            projectile-generic-command (concat projectile-generic-command " --path-separator=//"))))

  (:mkdir (file-name-directory projectile-cache-file))
  (:mkdir (file-name-directory projectile-known-projects-file))
  
  (projectile-mode 1)
  (projectile-session-mode 1)

  (set-keymap-parent rps-keymap-project projectile-command-map)

  (:hook-to 'tab-bar-tab-pre-close-functions #'rps-tab-bar-projectile-kill-buffers))

(cfg-pkg consult-projectile
  (:bind rps-keymap-leader
           "p" #'consult-projectile
           "P" rps-keymap-project)
  ;; due sorting-order 'recently-active, see https://gitlab.com/OlMon/consult-projectile/-/issues/6
  (:opt consult-projectile-use-projectile-switch-project t))

