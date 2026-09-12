;;; pgmacs.el -*- lexical-binding: t; -*-

(defun rps-pgmacs-enable-meow-motion-mode ()
  "Enable meow motion mode in pgmacs buffers.
Some pgmacs buffers return fundamental-mode for meow-mode-state-list
which enters normal mode and this logic is run after pgmacs mode hooks."
  (run-at-time 0 0 #'meow-motion-mode 1))

(cfg-pkg (:elpaca pgmacs
                  :host github
                  :repo "emarsden/pgmacs")
  (:after meow
    (:hook #'rps-pgmacs-enable-meow-motion-mode)))
