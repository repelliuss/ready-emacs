;;; os.el -*- lexical-binding: t; -*-

(setq command-line-ns-option-alist (and rps-system-mac-p command-line-ns-option-alist)
      command-line-x-option-alist (and rps-system-linux-p command-line-x-option-alist)
      x-gtk-use-system-tooltips (and rps-system-linux-p x-gtk-use-system-tooltips)
      find-program (and rps-system-windows-p (string-replace "grep" "find" (executable-find "grep"))))

;; Native compilation should hit early for future file load
(unless rps-system-android-p
  (setq native-comp-async-report-warnings-errors nil
        native-comp-speed 3)
  (add-to-list 'native-comp-eln-load-path (concat rps-dir-cache "eln/")))

(when rps-system-android-p
  (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin" (getenv "PATH")))
  (push "/data/data/com.termux/files/usr/bin" exec-path)
  (setq touch-screen-display-keyboard t))

(when rps-system-linux-p
  (add-to-list 'exec-path (file-name-concat rps-dir-home ".local" "bin")))

(when rps-system-windows-p
  (when (null (getenv-internal "HOME"))
    (setq abbreviated-home-dir nil))

  (setq w32-get-true-file-attributes nil  ; decrease file IO workload
        w32-pipe-read-delay 0             ; faster IPC
        w32-pipe-buffer-size (* 64 1024)) ; read more at a time (was 4K)

  (advice-add #'view-hello-file :override 
              (defun rps-view-hello-file-disabled ()
                (message "View hello file takes a long time to view so it is disabled.")))

  ;; This caused a problem where I feed a temp file to latex program
  ;; and it was not able comprehend ~1 abbrev of user directory of
  ;; Windows.
  (setq temporary-file-directory (file-truename temporary-file-directory)))

