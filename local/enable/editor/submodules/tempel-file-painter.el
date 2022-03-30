;;; tempel-file-painter.el -*- lexical-binding: t; -*-

;; TODO: needs something like p but finishes after
(use-package tempel
  :after file-painter
  :init
  (autoload #'tempel--templates "tempel")
  (setq file-painter-finder (defun tempel-get-template (name)
			      (cdr (assq (if (stringp name)
					     (intern name))
					 (tempel--templates))))
	file-painter-expander #'tempel-insert
	file-painter-rules '(((c-mode c++-mode) . (("inch" . ".*\\.c.*")
						   ("ponce")))))

  (file-painter-global-mode 1))
