;;; puni.el -*- lexical-binding: t; -*-

(setup puni
  (:bind ~keymap-edit
	 "s" #'puni-split
	 "]" #'puni-slurp-forward
	 "[" #'puni-slurp-backward
	 "{" #'puni-barf-backward
	 "}" #'puni-barf-forward
	 "r" #'puni-raise
	 "c" #'puni-convolute
	 "t" #'puni-transpose
	 "u" #'puni-splice
	 "z" #'puni-squeeze
         (:prefix "w"
           "r" #'~puni-change-round
           "c" #'~puni-change-curly
           "s" #'~puni-change-square
           "a" #'~puni-change-angle
           
           "R" #'puni-wrap-round
           "C" #'puni-wrap-curly
           "S" #'puni-wrap-square
           "A" #'puni-wrap-angle))

  (defun ~puni-change-round ()
    (interactive)
    (puni-wrap-round)
    (puni-syntactic-forward-punct)
    (puni-splice)
    (puni-backward-sexp-or-up-list))

  (defun ~puni-change-curly ()
    (interactive)
    (puni-wrap-curly)
    (puni-syntactic-forward-punct)
    (puni-splice)
    (puni-backward-sexp-or-up-list))

  (defun ~puni-change-square ()
    (interactive)
    (puni-wrap-square)
    (puni-syntactic-forward-punct)
    (puni-splice)
    (puni-backward-sexp-or-up-list))

  (defun ~puni-change-angle ()
    (interactive)
    (puni-wrap-angle)
    (puni-syntactic-forward-punct)
    (puni-splice)
    (puni-backward-sexp-or-up-list))

  (:after-feature meow
    (:bind ~keymap-normal
	  "d" #'~meow-puni-kill
	  "D" #'~meow-puni-kill-whole-line)
    
    (:set (prepend* meow-selection-command-fallback) '((~meow-puni-kill . puni-kill-line)
                                                       (meow-kill . puni-kill-line)))
    
    (defun ~meow-puni-kill ()
      "Kill region with #'puni-kill-active-region.

This command supports `meow-selection-command-fallback'."
      (interactive)
      (let ((select-enable-clipboard meow-use-clipboard))
        (when (meow--allow-modify-p)
	  (meow--with-selection-fallback
	   (cond
            ((equal '(expand . join) (meow--selection-type))
             (delete-indentation nil (region-beginning) (region-end)))
            (t
             (meow--prepare-region-for-kill)
             (puni-kill-active-region)))))))

    (defun ~meow-puni-kill-whole-line ()
      (interactive)
      (when (meow--allow-modify-p)
        (let ((beg (point-at-bol))
	      (end (point-at-eol)))
          (when (or (not puni-confirm-when-delete-unbalanced-active-region)
                    (puni-region-balance-p beg end)
                    (y-or-n-p "Delete the whole line will cause unbalanced state. Continue? "))
            (kill-whole-line))))))

  (:after-feature which-key
     (:set (prepend which-key-replacement-alist) '((nil . "^puni-") . (nil . "")))))

