;;; nerd-icons.el -*- lexical-binding: t; -*-

(cfg-pkg (:require nerd-icons)
  (dolist (font nerd-icons-font-names)
    (store-install
      (format "https://raw.githubusercontent.com/rainstormstudio/nerd-icons.el/main/fonts/%s" font)
      :url-font t
      :then (lambda () (rps-nerd-icons-set-font-order)))))

(cfg-pkg nerd-icons-completion
  (:hook-to 'marginalia-mode #'nerd-icons-completion-marginalia-setup)
  (nerd-icons-completion-mode 1))

(defun rps-nerd-icons-set-font-order ()
  ;; Icons are only propertied if inserted by nerd-icons functions. Below settings handle all characters by default.
  (cond
   (rps-system-windows-p (progn
                       (set-fontset-font t 'unicode "Segoe UI Emoji" nil 'prepend)
                       (set-fontset-font t 'unicode "Symbols Nerd Font Mono" nil 'prepend)))
   ((or rps-system-linux-p rps-system-android-p)
    (set-fontset-font t 'unicode "Symbols Nerd Font Mono" nil 'prepend))))
