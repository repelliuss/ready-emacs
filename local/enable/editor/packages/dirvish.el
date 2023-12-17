;;; dirvish.el -*- lexical-binding: t; -*-

(setup (:elpaca dirvish
                :host github
                :repo "alexluigit/dirvish"
                :files (:defaults "extensions/*.el"))
  (:require dirvish-emerge dirvish-icons)

  (:set dired-hide-details t
        dirvish-emerge-groups '(("Recent files" (predicate . recent-files-2h))
                                ("Documents" (extensions "pdf" "tex" "bib" "epub"))
                                ("Video" (extensions "mp4" "mkv" "webm"))
                                ("Pictures" (extensions "jpg" "png" "svg" "gif"))
                                ("Audio" (extensions "mp3" "flac" "wav" "ape" "aac"))
                                ("Archives" (extensions "gz" "rar" "zip"))
                                ("Emacs Lisp" (extensions "el"))
                                ("CXX" (extensions "c" "cpp" "h" "hpp" "hxx" "cxx" "cc" "hh")))

        (prepend dirvish-attributes) 'all-the-icons
        dirvish-all-the-icons-offset -0.06)
  
  (:face dirvish-hl-line (:inherit 'region))
  
  (dirvish-override-dired-mode)
  
  (:with-feature dired
    (:hook (defun ~dirvish-emerge-enable ()
             (run-at-time nil nil #'dirvish-emerge-mode)))))

