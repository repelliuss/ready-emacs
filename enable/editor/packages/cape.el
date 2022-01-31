;;; cape.el -*- lexical-binding: t; -*-

(defvar completion-map (make-sparse-keymap))

;; Add extensions
(use-package cape
  :straight (:host github :repo "minad/cape"
             :files ("*.el"))
  :after (corfu)
  :general
  (esc-map
   "c" completion-map)
  (completion-map
   "M-p" #'completion-at-point
   "M-t" #'complete-tag
   "M-d" #'cape-dabbrev
   "M-f" #'cape-file
   "M-k" #'cape-keyword
   "M-s" #'cape-symbol
   "M-a" #'cape-abbrev
   "M-i" #'cape-ispell
   "M-l" #'cape-line
   "M-w" #'cape-dict
   "M-\\" #'cape-tex
   "M-&" #'cape-sgml
   "M-r" #'cape-rfc1345)
  
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  ;; (add-to-list 'completion-at-point-functions #'cape-file)
  ;; (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-ispell)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  (add-to-list 'completion-at-point-functions #'cape-line))
