;;; pass.el -*- lexical-binding: t; -*-

(use-package pass
  :init
  (bind rps/open-map
	(bind-command "pass"
	  "p" #'consult-pass)
	"P" #'pass)
  
  :config
  (setq password-store-password-length 25
        pass-username-fallback-on-filename t)

  (auth-source-pass-enable)

  (defun consult-pass (arg entry)
    (interactive
     (list current-prefix-arg
           (progn
             (require 'consult)
             (consult--read (password-store-list)
                            :prompt "Pass: "
                            :sort nil
                            :require-match t
                            :category 'entry))))
    (funcall (pcase arg
	       ((pred (eq '-)) #'password-store-url)
	       ((pred (not null)) #'password-store-username-with-pass-fallback)
	       (_ #'password-store-copy))
	     entry))

  (defun password-store-username-with-pass-fallback (entry)
    (let ((secret (auth-source-pass-get "username" entry)))
      (password-store--save-field-in-kill-ring entry
					       (if (and secret
							pass-username-fallback-on-filename)
						   secret
						 (file-name-nondirectory entry))
					       "username"))))
