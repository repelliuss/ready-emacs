;;; pass.el -*- lexical-binding: t; -*-

;; TODO: create a note about pass

;;; Needs "PASSWORD_STORE_DIR" env variable to be set. See pass-fix-env submodule.
;;; Depends on progams gpg and pass most of the time.

(use-package pass
  :init
  (bind rps/open-map
	(bind-autoload "pass"
	  "p" #'consult-pass)
	"P" #'pass)
  
  :config
  (setq password-store-password-length 25
        pass-username-fallback-on-filename t)

  ;; for pass
  ;; add C:\msys64\mingw64\bin to Windows $Path environment variable, dunno why required
  ;; make sure your gpg config is correct, use gpg that comes with msys2 that is at C:\msys64\usr\bin
  ;; pacman -S pass
  ;; add C:\msys64\usr\bin to Windows $Path environment variable, dunno why required
  ;; for otp support
  ;; pacman -S mingw-w64-x86_64-perl
  ;; cpan App::cpanminus
  ;; cpanm Pass::OTP
  ;; pacman -S mingw-w64-x86_64-qrencode
  ;; cp https://github.com/tadfisher/pass-otp/blob/develop/otp.bash /usr/lib/password-store/extensions/
  ;; add C:\msys64\mingw64\bin\site_perl\5.32.1 to Windows $Path environment variable
  ;; make sure all binaries exist at given paths
  ;; to read QR codes, read an external QR reader and get URI and insert it instead of screenshot tool for now
  (when windows-p
    (setq password-store-executable "sh pass")

    (advice-add #'password-store--run-1
		:around
		(defun /password-store-use-mingw64-for-pass0 (fn &rest args)
		  (let ((password-store-executable "sh"))
		    (apply fn args))))

    (advice-add #'password-store--run-1
		:filter-args
		(defun /password-store-use-mingw64-for-pass1 (args)
		  (nconc (list (car args) "pass") (cdr args)))))

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
