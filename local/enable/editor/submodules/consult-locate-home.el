;;; consult-locate-home.el -*- lexical-binding: t; -*-

(use-package consult
  :after consult
  :config
  (add-to-list 'exec-path (expand-file-name "~/workspace/scripts"))
  
  (setq consult-locate-args  "plocate-home --basename --existing --ignore-case --regexp")

  (defun consult-locate-home (&optional initial)
    (interactive)
    (find-file (concat (getenv "HOME")
                       "/"
                       (consult--find "Locate: " #'consult--locate-builder initial))))

  (advice-add #'consult-locate :override #'consult-locate-home)
  
  :extend (orderless)
  (advice-add #'consult-locate-home :around #'consult--without-orderless))
