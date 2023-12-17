;;; dirvish.el -*- lexical-binding: t; -*-

(setup (:elpaca dirvish
                :host github
                :repo "alexluigit/dirvish"
                :files (:defaults "extensions/*.el"))
  (:set dired-hide-details t)
  (:face dirvish-hl-line (:inherit 'region))
  (dirvish-override-dired-mode)

  (:require dirvish-emerge dirvish-icons)
  ;; TODO: dirvish emerge
  (:set dirvish-emerge-groups '(("Recent files" (predicate . recent-files-2h))
                                ("Documents" (extensions "pdf" "tex" "bib" "epub"))
                                ("Video" (extensions "mp4" "mkv" "webm"))
                                ("Pictures" (extensions "jpg" "png" "svg" "gif"))
                                ("Audio" (extensions "mp3" "flac" "wav" "ape" "aac"))
                                ("Archives" (extensions "gz" "rar" "zip")))

        (prepend dirvish-attributes) 'all-the-icons
        dirvish-all-the-icons-offset -0.06))
