;;; orderless.el -*- lexical-binding: t; -*-

(use-package orderless
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles basic-remote partial-completion)))
	orderless-component-separator #'orderless-escapable-split-on-space
        orderless-matching-styles '(orderless-regexp
                                    orderless-initialism
                                    orderless-literal)
        orderless-style-dispatchers '(orderless-default-dispatcher))

  (add-to-list 'completion-styles-alist
               '(basic-remote basic-remote-try-completion basic-remote-all-completions))

  (set-face-attribute 'completions-first-difference nil :inherit nil)

  (defun file-path-remote-p (path)
    (string-match-p "\\`/[^/|:]+:" (substitute-in-file-name path)))

  (defun basic-remote-try-completion (string table pred point)
    (and (file-path-remote-p string)
         (completion-basic-try-completion string table pred point)))

  (defun basic-remote-all-completions (string table pred point)
    (and (file-path-remote-p string)
         (completion-basic-all-completions string table pred point)))

  :config
  (defun orderless-default-dispatcher (pattern _index _total)
    (cond
     ;; Ensure $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" pattern)
      `(orderless-regexp . ,(concat (substring pattern 0 -1) "[\x100000-\x10FFFD]*$")))
     ;; Ignore single !
     ((string= "!" pattern) `(orderless-literal . ""))
     ;; Without literal
     ((string-prefix-p "!" pattern) `(orderless-without-literal . ,(substring pattern 1)))
     ;; Character folding
     ((string-prefix-p "%" pattern) `(char-fold-to-regexp . ,(substring pattern 1)))
     ((string-suffix-p "%" pattern) `(char-fold-to-regexp . ,(substring pattern 0 -1)))
     ;; Initialism matching
     ((string-prefix-p "`" pattern) `(orderless-initialism . ,(substring pattern 1)))
     ((string-suffix-p "`" pattern) `(orderless-initialism . ,(substring pattern 0 -1)))
     ;; Literal matching
     ((string-prefix-p "=" pattern) `(orderless-literal . ,(substring pattern 1)))
     ((string-suffix-p "=" pattern) `(orderless-literal . ,(substring pattern 0 -1))))))

  ;; TODO: replace _ ignored varibales with _NAME
