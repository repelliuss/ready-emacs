;;; orderless.el -*- lexical-binding: t; -*-

(use-package orderless
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles basic-remote partial-completion)))
	orderless-component-separator #'orderless-escapable-split-on-space
        orderless-matching-styles '(orderless-regexp
                                    orderless-strict-initialism
                                    orderless-literal)
        orderless-style-dispatchers '(without-if-bang))

  (add-to-list 'completion-styles-alist
               '(basic-remote basic-remote-try-completion basic-remote-all-completions))

  (defun file-path-remote-p (path)
    (string-match-p "\\`/[^/|:]+:" (substitute-in-file-name path)))

  (defun basic-remote-try-completion (string table pred point)
    (and (file-path-remote-p string)
         (completion-basic-try-completion string table pred point)))

  (defun basic-remote-all-completions (string table pred point)
    (and (file-path-remote-p string)
         (completion-basic-all-completions string table pred point)))

  :config
  (defun without-if-bang (pattern _index _total)
    (cond
     ((string= "!" pattern) '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 1))))))

;; TODO: check usage again and check +orderless-dispatch in consult wiki

;; TODO: replace _ ignored varibales with _NAME
