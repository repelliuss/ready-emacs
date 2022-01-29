;;; vars.el -*- lexical-binding: t; -*-

(defgroup user nil
  "User customizations."
  :group 'emacs)

(defcustom theme-preferred-background 'light
  "Preferred background lightning for theme packages."
  :type '(choice (const 'light) (const 'dark)))

(defcustom cache-dir (concat user-emacs-directory "cache/")
  "Where cache files are stored."
  :type 'file)

(defcustom local-dir (concat user-emacs-directory "local/")
  "Where user files stored."
  :type 'file)
