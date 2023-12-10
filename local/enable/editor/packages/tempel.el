;;; tempel.el -*- lexical-binding: t; -*-

(setup tempel
  (:when-loaded
    (:bind tempel-map
	   "M-q" #'tempel-abort
	   "M-j" #'tempel-next
	   "M-k" #'tempel-previous
	   "M-d" #'tempel-kill
	   "M-c" #'tempel-done))

  (:set tempel-path (concat ~dir-local "tempel"))
  
  (:with-function ~tempel-setup-capf
    (:hook-into prog-mode text-mode conf-mode))


  (:after-feature meow
    (dolist (entry '(tempel-expand tempel-insert))
      (advice-add entry :after (lambda (&rest _) (meow-insert)))))

  (defun ~tempel-setup-capf ()
    (interactive)
    (add-hook 'completion-at-point-functions #'tempel-expand -90 'local)))

(setup (:require tempel-collection))

