;;; 10-vars.el -*- lexical-binding: t; -*-

(defconst @os-mac-p (eq system-type 'darwin)
  "Is current system Mac based?")

(defconst @os-linux-p (eq system-type 'gnu/linux)
  "Is current system Linux based?")

(defconst @os-windows-p (memq system-type '(cygwin windows-nt ms-dos))
  "Is current system Windows based?")

(defconst @os-bsd-p (or @os-mac-p (eq system-type 'berkeley-unix))
  "Is current system BSD based?")

(defconst @dir-home (expand-file-name "~/")
  "Where home directory is.")

(defcustom @dir-cache (expand-file-name (concat user-emacs-directory "cache/"))
  "Where cache files are stored."
  :type 'file)

;; TODO: use more local
(defcustom @dir-local (expand-file-name (concat user-emacs-directory "local/"))
  "Where user files stored."
  :type 'file)

(defcustom @theme-preferred-bg 'light
  "Preferred background lightning for theme packages."
  :type '(choice (const 'light) (const 'dark))
  :set (lambda (sym val)
         (if (and (fboundp #'theme-toggle-background)
                  (not (eq (symbol-value sym) val)))
             (theme-toggle-background)
           (set-default sym val))))

(defcustom @theme-default-light nil
  "Default light theme."
  :type 'symbol)

(defcustom @theme-default-dark nil
  "Default light theme."
  :type 'symbol)

(defcustom @theme-preferred 'modus-themes
  "Theme to be loaded with #'@theme-load-if-preferred."
  :type 'symbol)
