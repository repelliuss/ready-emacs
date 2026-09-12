;;; yasnippet.el -*- lexical-binding: t; -*-

(cfg-pkg yasnippet-snippets)

(cfg-pkg yasnippet
  ;; Don't insert snippet expansion before everything else as it is
  ;; surprising without completion to me.
  (:hook-to '(prog-mode org-mode) #'yas-minor-mode)

  (:after-this
    (:bind yas-minor-mode-map "<tab>" nil "TAB" nil)
    (:prepend yas-snippet-dirs
              (:join rps-dir-local "yasnippet"))
    (:mkdir rps-dir-local "yasnippet"))

  (:after meow
    (:hook-to 'yas-before-expand-snippet-hook #'meow-insert))

  (:after file-painter
    (:opt file-painter-finder (defun yas-lookup-snippet-noerr (name) (yas-lookup-snippet name major-mode 'noerr))
	      file-painter-expander #'yas-expand-snippet
	      file-painter-operator-hook 'yas-minor-mode-hook
	      file-painter-rules '((c-mode . (("source-file" . ".*\\.c.*")
					                      ("header-file")))))

    (file-painter-global-mode 1)))

