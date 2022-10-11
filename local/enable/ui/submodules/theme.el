;;; theme.el -*- lexical-binding: t; -*-

(defun theme-reset-current ()
  (interactive)
  (mapcar #'disable-theme custom-enabled-themes)
  (if (eq theme-preferred-background 'light)
      (load-theme theme-default-light 'no-confirm)
    (load-theme theme-default-dark 'no-confirm)))

(defun theme-toggle-background ()
  (interactive)
  (if (eq theme-preferred-background 'light)
      (setq theme-preferred-background 'dark)
    (setq theme-preferred-background 'light))
  (when (fboundp #'theme-reset-current)
    (theme-reset-current)))

(provide 'rps/ui/theme)
