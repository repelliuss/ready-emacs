;;; dirvish.el -*- lexical-binding: t; -*-

(cfg-pkg dirvish
  (dirvish-override-dired-mode 1)
  (:bind "?" #'dirvish-dispatch)
  (:prepend* dirvish-attributes '(file-time collapse subtree-state))

  (:after nerd-icons
    (:opt dirvish-subtree-state-style 'nerd)
    (:prepend dirvish-attributes 'nerd-icons)
    (:opt dirvish-path-separators (list
                                   (format "  %s " (nerd-icons-codicon "nf-cod-home"))
                                   (format "  %s " (nerd-icons-codicon "nf-cod-root_folder"))
                                   (format " %s " (nerd-icons-faicon "nf-fa-angle_right"))))))

