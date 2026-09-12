;;; cxx.el -*- lexical-binding: t; -*-

(cfg cc-mode
  (:after-this
    (:bind c-mode-base-map "<tab>" #'rps-c-indent-then-complete)
    (:prepend c-default-style (cons 'other "stroustrup")))
  (:after lsp-mode
    (:hook-to '(c-mode c++-mode c-ts-base-mode) #'lsp-deferred #'lsp-inlay-hints-mode)))

(defun rps-c-indent-then-complete ()
  (interactive)
  (if (= 0 (c-indent-line-or-region))
	  (completion-at-point)))
