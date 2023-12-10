;;; compile.el -*- lexical-binding: t; -*-

(setup compile
  (:elpaca nil)

  (:autoload comint-truncate-buffer)
  (:set compilation-scroll-output 'first-error)
  
  (add-hook 'compilation-filter-hook
	    (lambda () (with-silent-modifications
			 (ansi-color-apply-on-region compilation-filter-start (point)))))
  (add-hook 'compilation-filter-hook #'comint-truncate-buffer))
