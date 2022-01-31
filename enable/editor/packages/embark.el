;;; embark.el -*- lexical-binding: t; -*-

(use-package embark
  :general
  ("M-." #'embark-act
   "C-." #'embark-dwim)
  (minibuffer-local-map
   "M-b" #'embark-become
   "M-c" #'embark-collect-snapshot
   "M-e" #'embark-export)

  :attach (which-key)
  (setq which-key-use-C-h-commands nil)
  
  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :extend (which-key)
  (setq embark-indicators (cons #'embark-which-key-indicator
                                (delq 'embark-mixed-indicator
                                      embark-indicators)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator)

  (defun embark-which-key-indicator ()
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

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  :extend (vertico)
  (add-to-list 'embark-indicators #'embark-vertico-indicator)

  (defun embark-vertico-indicator ()
    (let ((fr face-remapping-alist))
      (lambda (&optional keymap _targets prefix)
        (when (bound-and-true-p vertico--input)
          (setq-local face-remapping-alist
                      (if keymap
                          (cons '(vertico-current . embark-target) fr)
                        fr)))))))

;; TODO: check doom how it handles autoloads
;; TODO: add embark-consult
;; TODO: consider a preview key like in doom
;; BUG: xref-find-references doesn't work
