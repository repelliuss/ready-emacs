;;; dired.el ---  -*- lexical-binding: t; -*-

(setq dired-listing-switches "-ahl -v --group-directories-first")

(add-hook 'dired-mode-hook #'dired-hide-details-mode)

(provide 'ready/tools/dired)
