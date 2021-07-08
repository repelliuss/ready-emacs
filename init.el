;;; init.el -*- lexical-binding: t; -*-

;; TODO: Change rps

(defvar rps/emacs-directory (concat user-emacs-directory "rps/"))

(defun rps/load  (module files &optional packages-p)
  (let* ((module-name (symbol-name module))
         (module-path (concat rps/emacs-directory module-name "/")))
    (require (intern (concat "rps-" module-name)) (concat module-path "config"))
    (let ((path (concat module-path (if packages-p
                                        "packages/"
                                      "submodules/"))))
      (dolist (file files)
        (load (concat path (symbol-name file)) t t)))))

(defmacro rps/load-submodules (module &rest submodules)
  `(rps/load ,module ',submodules))

(defmacro rps/load-packages (module &rest packages)
  `(rps/load ,module ',packages t))

(rps/load-submodules 'base package window)

(load (concat user-emacs-directory "config") t t)

(use-package gcmh
  :demand
  :config
  (setq gcmh-idle-delay 5)
  (gcmh-mode 1))

;; TODO: Remove this
(message "*** Emacs loaded in %s with %d garbage collections."
     (format "%.2f seconds"
             (float-time
              (time-subtract after-init-time before-init-time))) gcs-done)
