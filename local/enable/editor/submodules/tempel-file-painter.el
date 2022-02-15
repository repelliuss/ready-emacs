;;; tempel-file-painter.el -*- lexical-binding: t; -*-

(use-package tempel
  :after file-painter
  :init
  (autoload #'tempel--templates "tempel")
  (setq file-painter-finder (defun tempel-get-template (name)
			      (cdr (assq (if (stringp name)
					     (intern name))
					 (tempel--templates))))
	file-painter-expander #'tempel-insert
	file-painter-rules '((c-mode . (("source-file" . ".*\\.c.*")
					("header-file")))))

  (file-painter-global-mode 1))
