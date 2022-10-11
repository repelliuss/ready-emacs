;;; vars.el -*- lexical-binding: t; -*-

(defgroup user nil
  "User customizations."
  :group 'emacs)

(defcustom theme-preferred-background 'light
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

(defcustom theme-preferred 'modus-themes
  "Theme to be loaded with #'maybe-load-theme."
  :type 'symbol)

(defcustom cache-dir (expand-file-name (concat user-emacs-directory "cache/"))
  "Where cache files are stored."
  :type 'file)

;; TODO: use more local
(defcustom local-dir (expand-file-name (concat user-emacs-directory "local/"))
  "Where user files stored."
  :type 'file)

(defcustom home-dir (expand-file-name "~/")
  "Where home directory is."
  :type 'file)
