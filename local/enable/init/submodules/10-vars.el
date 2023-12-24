;;; 10-vars.el -*- lexical-binding: t; -*-

(defgroup user nil
  "All safe to customize settings for any user."
  :prefix "~")

(defconst ~os-mac-p (eq system-type 'darwin)
  "Is current system Mac based?")

(defconst ~os-linux-p (eq system-type 'gnu/linux)
  "Is current system Linux based?")

(defconst ~os-windows-p (memq system-type '(cygwin windows-nt ms-dos))
  "Is current system Windows based?")

(defconst ~os-bsd-p (or ~os-mac-p (eq system-type 'berkeley-unix))
  "Is current system BSD based?")

(defcustom ~dir-home (expand-file-name "~/")
  "Where home directory is."
  :type 'file)

(defcustom ~dir-cache (expand-file-name (concat user-emacs-directory "cache/"))
  "Where cache files are stored."
  :type 'file)

;; TODO: use more local
(defcustom ~dir-local (expand-file-name (concat user-emacs-directory "local/"))
  "Where user files stored."
  :type 'file)

(defcustom ~dir-local-pkg (expand-file-name (concat user-emacs-directory "local/package/"))
  "Where local packages are stored."
  :type 'file)

(defcustom ~theme-preferred-bg 'light
  "Preferred background lightning for theme packages."
  :type '(choice (const 'light) (const 'dark))
  :set (lambda (sym val)
         (if (and (fboundp #'theme-toggle-background)
                  (not (eq (symbol-value sym) val)))
             (theme-toggle-background)
           (set-default sym val))))

(defvar ~theme-default-light nil
  "Default light theme.")

(defvar ~theme-default-dark nil
  "Default light theme.")

(defcustom ~theme-preferred 'modus-themes-tinted
  "Theme to be loaded with #'~theme-load-if-preferred."
  :type 'symbol)

(defcustom ~key-leader-prefix "SPC"
  "Leader prefix."
  :type 'string)

(defcustom ~key-local-leader-prefix "SPC"
  "Leader local prefix."
  :type 'string)

(defcustom ~font-preferred 'iosevka-term-ss04
  "A symbol describing the default font."
  :type 'symbol)

(defvar ~keymap-leader (make-sparse-keymap)
  "Leader map.")

(defvar ~keymap-normal (make-sparse-keymap)
  "Normal map.")

(defvar ~keymap-open (make-sparse-keymap)
  "Open map.")

(defvar ~keymap-edit (make-sparse-keymap)
  "Leader map.")

(defvar ~keymap-toggle (make-sparse-keymap)
  "Open map.")

(defvar ~keymap-buffer (make-sparse-keymap)
  "Buffer map.")

(defvar ~keymap-project (make-sparse-keymap)
  "Project map.")

(defvar ~keymap-window (make-sparse-keymap)
  "Window map.")

(defvar ~keymap-search (make-sparse-keymap)
  "Search map.")

(defvar ~keymap-file (make-sparse-keymap)
  "File map.")

(defvar ~keymap-toggle (make-sparse-keymap)
  "Toggle map.")

(defvar ~keymap-workspace (make-sparse-keymap)
  "Workspace map.")

(defvar ~keymap-quit (make-sparse-keymap)
  "Quit map.")

(defvar ~keymap-completion (make-sparse-keymap)
  "Completion map.")

(defvar ~theme-register nil
  "All registered themes for current sesssion.")
