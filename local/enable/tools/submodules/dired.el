;;; dired.el ---  -*- lexical-binding: t; -*-

(setup dired
  (:elpaca nil)
  (:set dired-dwim-target t
	    dired-auto-revert-buffer t
	    dired-hide-details-hide-symlink-targets nil
	    dired-recursive-copies 'always
	    dired-recursive-deletes 'top
	    dired-create-destination-dirs 'ask
	    dired-listing-switches "-ahl -v --group-directories-first"))
