;;; grammer.el -*- lexical-binding: t; -*-

(defun ~grammer-find-repetitions ()
  "Find repetitions of words with at most 100 words between them."
  (interactive)
  (occur "\\<\\(\\w\\{5,\\}\\)\\>\\(?:\\(?:\\W*\\<\\w+\\>\\)\\{0,100\\}\\W*\\1\\)+"))

(defun ~grammer-highlight-repetitions ()
  "Find repetitions of words with at most 100 words between them."
  (interactive)
  (highlight-regexp "\\<\\(\\w\\{5,\\}\\)\\>\\(?:\\(?:\\W*\\<\\w+\\>\\)\\{0,100\\}\\W*\\1\\)+"))
