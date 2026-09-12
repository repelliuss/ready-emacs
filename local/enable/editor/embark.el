;;; embark.el -*- lexical-binding: t; -*-

(cfg-pkg embark
  (:bind ((:global-map) "C-." #'embark-act)
	     (minibuffer-local-map
	      (:prefix "M-"
	        "b" #'embark-become
	        "c" #'embark-collect
	        "e" #'embark-export))
	     (help-map
	      "B" #'embark-bindings))

  (:after which-key
    (:opt embark-indicators '(rps-embark-which-key-indicator
				              embark-highlight-indicator
				              embark-isearch-highlight-indicator)
	      prefix-help-command #'embark-prefix-help-command)

    (:advice-to 'embark-completing-read-prompter :around #'rps-embark-hide-which-key-indicator))


  (:after-this
    (:after vertico
      (:prepend embark-indicators #'rps-embark-vertico-indicator)
      (:face embark-target (:inherit 'lazy-highlight)))))

(cfg-pkg embark-consult)

(defun rps-embark-which-key-indicator ()
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

(defun rps-embark-hide-which-key-indicator (fn &rest args)
  "Hide the which-key indicator immediately when using the completing-read prompter."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
         (remq #'rps-embark-which-key-indicator embark-indicators)))
    (apply fn args)))

(defun rps-embark-vertico-indicator ()
  (let ((fr face-remapping-alist))
    (lambda (&optional keymap _targets prefix)
      (when (bound-and-true-p vertico--input)
        (setq-local face-remapping-alist (if keymap
                                             (cons '(vertico-current . embark-target) fr)
                                           fr))))))
