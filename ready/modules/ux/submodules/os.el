;;; os.el -*- lexical-binding: t; -*-

(let* ((mac-p     (eq system-type 'darwin))
       (linux-p   (eq system-type 'gnu/linux))
       (windows-p (memq system-type '(cygwin windows-nt ms-dos)))
       (bsd-p     (or mac-p (eq system-type 'berkeley-unix))))

  (unless mac-p   (setq command-line-ns-option-alist nil))
  (unless linux-p (setq command-line-x-option-alist nil))

  (unless windows-p
    (setq selection-coding-system 'utf-8))

  (when windows-p
    (when (null (getenv-internal "HOME"))
      (setenv "HOME" (getenv "USERPROFILE"))
      (setq abbreviated-home-dir nil))

    (setq w32-get-true-file-attributes nil  ; decrease file IO workload
          w32-pipe-read-delay 0             ; faster IPC
          w32-pipe-buffer-size (* 64 1024)) ; read more at a time (was 4K)

    (with-eval-after-load 'ready/editor/fd
      (setq consult-fd-args (concat consult-fd-args
                                    "--path-separator=/")))))

;; TODO: is it a good idea to not expose this variables and not do changes in place

(provide 'ready/ux/os)
