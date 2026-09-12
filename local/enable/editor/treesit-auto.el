;;; treesit-auto.el -*- lexical-binding: t; -*-

(cfg emacs
  (:prepend treesit-extra-load-path (:join-d rps-dir-cache "tree-sitter")))

(cfg-pkg (:require treesit-auto)
  (:opt treesit-auto-install 'prompt)
  (:remove treesit-auto-langs 'yaml)
  (global-treesit-auto-mode 1)

  (when (require 'async)
    (unless (treesit-ready-p 'cpp 'quiet)
      (message "Installing all treesit language grammars, this may take a while...")
      (rps-async
       `(lambda ()
          (require 'treesit-auto)
          (let ((treesit-auto-install t)
                (user-emacs-directory ,rps-dir-cache))
            (treesit-auto-install-all)))
       (lambda (_)
         (message "All tree-sitter grammars are installed!"))))))

