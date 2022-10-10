;;; compile.el -*- lexical-binding: t; -*-

(use-package compile
  :straight (:type built-in)
  :config
  (setq compilation-scroll-output 'first-error)
  
  (add-hook 'compilation-filter-hook
	    (lambda () (with-silent-modifications
			 (ansi-color-apply-on-region compilation-filter-start (point)))))

  (autoload 'comint-truncate-buffer "comint" nil t)
  (add-hook 'compilation-filter-hook #'comint-truncate-buffer))
