;;; glsl.el -*- lexical-binding: t; -*-

(use-package glsl-mode)

(use-package company-glsl
  :after (glsl-mode cape)
  :if (executable-find "glslangValidator")
  :init
  (add-hook 'glsl-mode-hook (lambda ()
			      (setq-local completion-at-point-functions
					  (mapcar #'cape-company-to-capf
						 (list #'company-glsl))))))
