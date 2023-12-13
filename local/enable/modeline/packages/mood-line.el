;;; mood-line.el -*- lexical-binding: t; -*-

(setup mood-line
  (mood-line-mode 1)
  (:face mode-line (:overline t :foreground 'unspecified :background 'unspecified :inherit 'default)
         mode-line-inactive (:overline t :background 'unspecified :inherit 'default)))

