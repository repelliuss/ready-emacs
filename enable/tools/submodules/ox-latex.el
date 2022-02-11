;;; ox-latex.el -*- lexical-binding: t; -*-

(use-package ox-latex
  :straight (:type built-in)
  :config
  (setq org-latex-toc-command "\\newpage \\tableofcontents"
        org-latex-listings 'minted
        org-latex-pdf-process
        '("latexmk -shell-escape -f -pdf -%latex -interaction=nonstopmode -output-directory=%o %f"
          "latexmk -shell-escape -f -pdf -%latex -interaction=nonstopmode -output-directory=%o %f")))
