;;; font-list.el -*- lexical-binding: t; -*-

(define-derived-mode font-list-mode tabulated-list-mode "Font-List"
  "Major mode for listing available fonts."
  (setq tabulated-list-format [("Font Family" 40 t) ("Preview" 60 nil)]
        tabulated-list-padding 2
        tabulated-list-sort-key (cons "Font Family" nil))
  (tabulated-list-init-header))

(defun font-list--is-special-p (font-name)
  "Check if FONT-NAME is likely a symbol, emoji, or icon font."
  (string-match-p (rx (or "emoji" "symbol" "icon" "nerd" "powerline"
                          "awesome" "material" "unicode" "math"))
                  (downcase font-name)))

(defun font-list--preview-text (font-name)
  "Return appropriate preview text for FONT-NAME."
  (if (font-list--is-special-p font-name)
      (propertize "😀🎉🌟💡🚀♠♣♥♦★☆←→↑↓∑∏∫√∞◆○●□■△♪♫"
                  'face `(:family ,font-name))
    (propertize "The quick brown fox jumps over the lazy dog 0123456789"
                'face `(:family ,font-name))))

(defun font-list ()
  "Display a list of all available font families in a buffer."
  (interactive)
  (let* ((fonts (seq-uniq (sort (font-family-list) #'string<)))
         (buffer (get-buffer-create "*Font List*")))
    (with-current-buffer buffer
      (font-list-mode)
      (setq tabulated-list-entries
            (mapcar (lambda (font)
                      (list font
                            (vector font
                                    (font-list--preview-text font))))
                    fonts))
      (tabulated-list-print t)
      (goto-char (point-min)))
    (pop-to-buffer buffer)))
