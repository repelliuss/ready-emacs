;;; embark.el -*- lexical-binding: t; -*-

(setup embark
  (:bind ((:global-map) "C-." #'embark-act)
	 (minibuffer-local-map
	  (:prefix "M-"
	    "b" #'embark-become
	    "c" #'embark-collect
	    "e" #'embark-export))
	 (help-map
	  "B" #'embark-bindings))
  
  (:after-feature which-key
    (:set embark-indicators '(~embark-which-key-indicator
				 embark-highlight-indicator
				 embark-isearch-highlight-indicator)
	     prefix-help-command #'embark-prefix-help-command)
    
    (:with-function embark-completing-read-prompter
      (:advice :around #'~embark-hide-which-key-indicator))

    (defun ~embark-which-key-indicator ()
      "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
      (lambda (&optional keymap targets prefix)
	(if (null keymap)
            (which-key--hide-popup-ignore-command)
	  (which-key--show-keymap
	   (if (eq (plist-get (car targets) :type) 'embark-become)
               "Become"
             (format "Act on %s '%s'%s"
                     (plist-get (car targets) :type)
                     (embark--truncate-target (plist-get (car targets) :target))
                     (if (cdr targets) "…" "")))
	   (if prefix
               (pcase (lookup-key keymap prefix 'accept-default)
		 ((and (pred keymapp) km) km)
		 (_ (key-binding prefix 'accept-default)))
             keymap)
	   nil nil t (lambda (binding)
                       (not (string-suffix-p "-argument" (cdr binding))))))))

    (defun ~embark-hide-which-key-indicator (fn &rest args)
      "Hide the which-key indicator immediately when using the completing-read prompter."
      (which-key--hide-popup-ignore-command)
      (let ((embark-indicators
             (remq #'~embark-which-key-indicator embark-indicators)))
	(apply fn args))))
  
  
  (:after-feature vertico
    (:set (prepend embark-indicators) #'~embark-vertico-indicator)
    (:face embark-target (:inherit 'lazy-highlight))
    
    (defun ~embark-vertico-indicator ()
      (let ((fr face-remapping-alist))
	(lambda (&optional keymap _targets prefix)
	  (when (bound-and-true-p vertico--input)
            (setq-local face-remapping-alist
			(if keymap
                            (cons '(vertico-current . embark-target) fr)
			  fr))))))))

