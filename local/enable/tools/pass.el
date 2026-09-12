;;; pass.el -*- lexical-binding: t; -*-

(enable-when (not rps-system-android-p))

(store-thread
  (store-install "pass")

  :then
  (store-install "pass-otp"
    :then
    (lambda ()
      (cfg-pkg pass
        (:bind (rps-keymap-open
                "p" (setq rps-password-store-map (make-sparse-keymap)))
               (rps-password-store-map
                "p" #'pass
                "c" #'password-store-copy
                "u" #'password-store-url
                "f" #'password-store-copy-field
                "o" #'password-store-otp-token-copy))
        (:opt password-store-password-length 25
              pass-username-fallback-on-filename t)
        (when rps-user-home-desktop-p
          (setenv "PASSWORD_STORE_DIR" (:join-d rps-dir-home "safe" "pass")))
        (auth-source-pass-enable)))))

(defun password-store-username (entry)
  "Add password's username field for ENTRY into the kill ring.

Clear previous password from the kill ring.  Pointer to the kill
ring is stored in `password-store-kill-ring-pointer'.  Password
is cleared after `password-store-time-before-clipboard-restore'
seconds."
  (interactive (list (password-store--completing-read t)))
  (password-store-get-field
   entry
   "username"
   (lambda (password)
     (if password
         (password-store--save-field-in-kill-ring entry password "username")
       (password-store--save-field-in-kill-ring entry (file-name-nondirectory entry) "username")))))
