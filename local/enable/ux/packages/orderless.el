;;; orderless.el -*- lexical-binding: t; -*-

(setup (:require orderless)
  (:option completion-styles '(orderless basic)
	   completion-category-defaults nil
	   completion-category-overrides '((file (styles basic partial-completion)))
	   orderless-component-separator #'orderless-escapable-split-on-space
           orderless-matching-styles '(orderless-regexp orderless-initialism orderless-literal)
           orderless-style-dispatchers '(~orderless-dispatcher))

  ;; TODO: see face
  ;; (set-face-attribute 'completions-first-difference nil :inherit nil)

  (defun ~orderless-dispatcher (pattern _index _total)
    (cond
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." pattern))
      `(orderless-regexp . ,(concat "\\." (substring pattern 1) (~orderless--consult-suffix))))
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
