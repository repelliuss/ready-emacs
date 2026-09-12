;;; eww.el -*- lexical-binding: t; -*-

(cfg eww
  (:after-this
    (:opt url-configuration-directory (concat rps-dir-cache "url")
          eww-auto-rename-buffer 'title
          eww-bookmarks-directory (:join rps-dir-data "eww" "bookmarks")
          eww-default-download-directory (:join rps-dir-data "eww" "download")
          shr-max-image-proportion 0.7
          shr-max-width nil
          shr-discard-aria-hidden t
          shr-cookie-policy nil
          shr-bullet (concat (char-to-string ?–) " ")
          shr-table-vertical-line "|"
          shr-external-rendering-functions '((pre . eww-tag-pre)))
    (:mkdir eww-bookmarks-directory)
    (:mkdir eww-default-download-directory))

  (:hook #'visual-line-mode #'unpackaged/eww-imenu-setup))

;; Code is copied from https://github.com/andreasjansson/language-detection.el?tab=readme-ov-file#eww-syntax-highlighting
;; Following code adds functionality render code blocks in EWW buffer.
(cfg-pkg language-detection
  (defun eww-tag-pre (dom)
    (let ((shr-folding-mode 'none)
          (shr-current-font 'default))
      (shr-ensure-newline)
      (insert (eww-fontify-pre dom))
      (shr-ensure-newline)))

  (defun eww-fontify-pre (dom)
    (with-temp-buffer
      (shr-generic dom)
      (let ((mode (eww-buffer-auto-detect-mode)))
        (when mode
          (eww-fontify-buffer mode)))
      (buffer-string)))

  (defun eww-fontify-buffer (mode)
    (delay-mode-hooks (funcall mode))
    (font-lock-default-function mode)
    (font-lock-default-fontify-region (point-min)
                                      (point-max)
                                      nil))

  (defun eww-buffer-auto-detect-mode ()
    (let* ((map '((ada ada-mode)
                  (awk awk-mode)
                  (c c-mode)
                  (cpp c++-mode)
                  (clojure clojure-mode lisp-mode)
                  (csharp csharp-mode java-mode)
                  (css css-mode)
                  (dart dart-mode)
                  (delphi delphi-mode)
                  (emacslisp emacs-lisp-mode)
                  (erlang erlang-mode)
                  (fortran fortran-mode)
                  (fsharp fsharp-mode)
                  (go go-mode)
                  (groovy groovy-mode)
                  (haskell haskell-mode)
                  (html html-mode)
                  (java java-mode)
                  (javascript javascript-mode)
                  (json json-mode javascript-mode)
                  (latex latex-mode)
                  (lisp lisp-mode)
                  (lua lua-mode)
                  (matlab matlab-mode octave-mode)
                  (objc objc-mode c-mode)
                  (perl perl-mode)
                  (php php-mode)
                  (prolog prolog-mode)
                  (python python-mode)
                  (r r-mode)
                  (ruby ruby-mode)
                  (rust rust-mode)
                  (scala scala-mode)
                  (shell shell-script-mode)
                  (smalltalk smalltalk-mode)
                  (sql sql-mode)
                  (swift swift-mode)
                  (visualbasic visual-basic-mode)
                  (xml sgml-mode)))
           (language (language-detection-string
                      (buffer-substring-no-properties (point-min) (point-max))))
           (modes (cdr (assoc language map)))
           (mode (cl-loop for mode in modes
                          when (fboundp mode)
                          return mode)))
      (when (fboundp mode)
        mode))))

;; Code is copied from https://github.com/alphapapa/unpackaged.el?tab=readme-ov-file#eww-imenu-support
;; Following code offers HTML links and headings as imenu items.
(defun unpackaged/eww-imenu-index ()
    "Return Imenu index for current EWW buffer.
Index includes links and headings."
    (let ((shr-heading-faces '( shr-h1 shr-h2 shr-h3 shr-h4 shr-h5
                                shr-h6 shr-heading)))
      (cl-labels ((range-matching (property predicate)
                    "Return (BEG . END) cons from point where PROPERTY matches PREDICATE.
  PREDICATE is used for `text-property-search-forward', which see."
                    (when-let* ((match (text-property-search-forward property nil predicate))
                                (end (cl-loop
                                      for next-change-pos = (prop-match-end match) then next-change-pos
                                      for next-change-pos = (next-single-property-change next-change-pos property)
                                      when next-change-pos
                                      for end-pos = next-change-pos
                                      while (funcall predicate nil (get-text-property next-change-pos property))
                                      finally return end-pos)))
                      (cons (prop-match-beginning match) end)))
                  (shr-heading-p (_ value-of)
                    (cl-typecase value-of
                      (atom (member value-of shr-heading-faces))
                      (list (seq-intersection value-of shr-heading-faces)))))
        (let ((links (save-excursion
                       (goto-char (point-min))
                       (delete-dups
                        (cl-loop for url = (get-text-property (point) 'shr-url)
                                 when url collect (cons (format "%s <%s>"
                                                                (button-label (button-at (point)))
                                                                url)
                                                        (point))
                                 for pos = (next-single-property-change (point) 'shr-url)
                                 while pos do (goto-char pos)))))
              (headings (save-excursion
                          (goto-char (point-min))
                          (cl-loop for (next-beg . next-end) = (range-matching 'face #'shr-heading-p)
                                   while next-beg
                                   for text = (buffer-substring next-beg next-end)
                                   collect (cons text next-beg)
                                   and do (goto-char next-end)))))
          (list (cons "Headings" headings)
                (cons "Links" links))))))

  (defun unpackaged/eww-imenu-goto (_label position)
    "Go to POSITION and call `eww-follow-link' if one is there."
    (goto-char position)
    (when (button-at (point))
      (declare-function eww-follow-link "eww")
      (call-interactively #'eww-follow-link)))

  (defun unpackaged/eww-imenu-setup ()
    "Setup Imenu in EWW buffers."
    (setq-local imenu-create-index-function #'unpackaged/eww-imenu-index
                imenu-default-goto-function #'unpackaged/eww-imenu-goto))

