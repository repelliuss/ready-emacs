;;; os.el -*- lexical-binding: t; -*-

(unless ~os-mac-p   (setq command-line-ns-option-alist nil))
(unless ~os-linux-p (setq command-line-x-option-alist nil))

(unless ~os-windows-p
  (setq selection-coding-system 'utf-8))

(when ~os-linux-p
  (setq x-gtk-use-system-tooltips nil))

(when ~os-windows-p
  (when (null (getenv-internal "HOME"))
    (setq abbreviated-home-dir nil))

  (setq w32-get-true-file-attributes nil  ; decrease file IO workload
        w32-pipe-read-delay 0             ; faster IPC
        w32-pipe-buffer-size (* 64 1024)) ; read more at a time (was 4K)

  (advice-add #'view-hello-file :override (defun ~windows-view-hello-file ()
                                            (message "View hello file takes a long time view so it is disabled."))))
