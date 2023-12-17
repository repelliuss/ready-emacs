;;; topspace.el -*- lexical-binding: t; -*-

(setup topspace
  (:with-function ~topspace-on-non-dirvish
    (:hook-into dired-mode)))

(defun ~topspace-on-non-dirvish ()
                    (if dirvish-override-dired-mode
                        (topspace-mode -1)
                      (topspace-mode 1)))
