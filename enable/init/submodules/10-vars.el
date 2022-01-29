;;; vars.el -*- lexical-binding: t; -*-

(defgroup user nil
  "User customizations."
  :group 'emacs)

(defcustom theme-preferred-background 'dark
  "Preferred background lightning for theme packages."
  :type '(choice (const 'light) (const 'dark))
  :set (lambda (sym val)
         (if (and (fboundp #'theme-toggle-background)
                  (not (eq (symbol-value sym) val)))
             (theme-toggle-background)
           (set-default sym val))))

(defcustom theme-default-light nil
  "Default light theme."
  :type 'symbol)

(defcustom theme-default-dark nil
  "Default light theme."
  :type 'symbol)

(defcustom cache-dir (concat user-emacs-directory "cache/")
  "Where cache files are stored."
  :type 'file)

(defcustom local-dir (concat user-emacs-directory "local/")
  "Where user files stored."
  :type 'file)
