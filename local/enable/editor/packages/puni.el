;;; puni.el -*- lexical-binding: t; -*-

(use-package puni
  :attach rps/editor/edit
  (bind rps/edit-map
	"s" #'puni-split
	"]" #'puni-slurp-forward
	"[" #'puni-slurp-backward
	"{" #'puni-barf-backward
	"}" #'puni-barf-forward
	"r" #'puni-raise
	"c" #'puni-convolute
	"t" #'puni-transpose
	"u" #'puni-splice
	"z" #'puni-squeeze)
  
  :extend (meow)
  (add-to-list 'meow-selection-command-fallback '(meow-kill . puni-kill-line))

  (defun meow-puni-kill ()
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

  (defun meow-puni-kill-whole-line ()
    (interactive)
    (when (meow--allow-modify-p)
      (let ((beg (point-at-bol))
	    (end (point-at-eol)))
        (when (or (not puni-confirm-when-delete-unbalanced-active-region)
                  (puni-region-balance-p beg end)
                  (y-or-n-p "Delete the whole line will cause unbalanced state.  \
Continue? "))
          (kill-whole-line)))))

  (bind rps/normal-map
	"d" #'meow-puni-kill-whole-line
	"D" #'meow-puni-kill)

  :extend (which-key)
  (add-to-list 'which-key-replacement-alist '((nil . "^puni-") . (nil . ""))))

