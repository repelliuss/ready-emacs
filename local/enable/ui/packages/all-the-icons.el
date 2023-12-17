;;; all-the-icons.el -*- lexical-binding: t; -*-

(setup (:require all-the-icons)
  (:if (display-graphic-p))
  (:set all-the-icons-scale-factor 1.0))

(setup all-the-icons-completion
    (:with-feature vertico
      (:hook all-the-icons-completion-mode)))

(setup all-the-icons-dired
    (:set all-the-icons-dired-v-adjust -0.05
          all-the-icons-dired-monochrome nil)
    (:with-feature dired
      (:hook #'all-the-icons-dired-mode)))
