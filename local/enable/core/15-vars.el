;;; 15-vars.el -*- lexical-binding: t; -*-

(defconst rps-system-mac-p (eq system-type 'darwin)
  "Is current system Mac based?")

(defconst rps-system-linux-p (eq system-type 'gnu/linux)
  "Is current system Linux based?")

(defconst rps-system-windows-p (memq system-type '(cygwin windows-nt ms-dos))
  "Is current system Windows based?")

(defconst rps-system-android-p (eq system-type 'android)
  "Is current system Android based?")

(defconst rps-system-wsl-two-p (string-match-p "WSL" (shell-command-to-string "cat /proc/version"))
  "Is current version WSL 2")

(defconst rps-system-wsl-one-p (and (string-match-p "Microsoft" (shell-command-to-string "uname -r")) t)
  "Version of WSL")

(defconst rps-system-wsl-p (or rps-system-wsl-one-p rps-system-wsl-two-p)
  "Version of WSL")

(defconst rps-system-mingw64-p (and rps-system-windows-p (equal "MINGW64" (getenv "MSYSTEM")))
  "Is current Emacs environment windows OS use MSYS2 Mingw64 system shell?")

(defconst rps-user-work-p (string= "batuhanolmez" (downcase (system-name))))

(defconst rps-user-home-desktop-p (string= "rps-desktop-win" (downcase (system-name))))

(defcustom rps-key-leader-prefix "SPC"
  "Leader prefix."
  :type 'string)

(defcustom rps-key-local-leader-prefix "SPC"
  "Leader local prefix."
  :type 'string)

(defcustom rps-dir-home (expand-file-name "~/")
  "Where home directory is."
  :type 'file)

(defcustom rps-dir-cache (expand-file-name (concat user-emacs-directory "cache/"))
  "Where cache files are stored."
  :type 'file)

(defcustom rps-dir-local (expand-file-name (concat user-emacs-directory "local/"))
  "Where user files stored."
  :type 'file)

(defcustom rps-dir-local-pkg (expand-file-name (concat user-emacs-directory "local/package/"))
  "Where local packages are stored."
  :type 'file)

(defcustom rps-dir-data (expand-file-name (concat rps-dir-home "emacs-data/"))
  "Where emacs data is stored."
  :type 'file)

(defcustom rps-dir-font (expand-file-name "font/" rps-dir-cache)
  "where fonts are stored."
  :type 'file)

(defvar rps-keymap-leader (make-sparse-keymap)
  "Leader map.")

(defvar rps-keymap-normal (make-sparse-keymap)
  "Normal map.")

(defvar rps-keymap-open (make-sparse-keymap)
  "Open map.")

(defvar rps-keymap-edit (make-sparse-keymap)
  "Leader map.")

(defvar rps-keymap-buffer (make-sparse-keymap)
  "Buffer map.")

(defvar rps-keymap-project (make-sparse-keymap)
  "Project map.")

(defvar rps-keymap-window (make-sparse-keymap)
  "Window map.")

(defvar rps-keymap-search (make-sparse-keymap)
  "Search map.")

(defvar rps-keymap-file (make-sparse-keymap)
  "File map.")

(defvar rps-keymap-toggle (make-sparse-keymap)
  "Toggle map.")

(defvar rps-keymap-workspace (make-sparse-keymap)
  "Workspace map.")

(defvar rps-keymap-quit (make-sparse-keymap)
  "Quit map.")

(defvar rps-keymap-completion (make-sparse-keymap)
  "Completion map.")

(defvar rps-keymap-note (make-sparse-keymap)
  "Note map.")

(defvar store-install-state-dir (file-name-concat rps-dir-cache "installation"))

(setq user-full-name "repelliuss"
      user-mail-address "repelliuss@gmail.com")

