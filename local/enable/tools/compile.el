;;; compile.el -*- lexical-binding: t; -*-

(cfg compile
  (:autoload comint-truncate-buffer)
  (:opt compilation-scroll-output 'first-error)
  (:prepend display-buffer-alist
            '(rps-display-buffer-compilation-mode-p
              (display-buffer-at-bottom 
               display-buffer-in-side-window)
              (window-height . 0.25)
              (side . bottom)
              (slot . -6)))
  (:hook-to 'compilation-filter-hook #'comint-truncate-buffer #'rps-compilation-colorize)
  (:after-this
    (:bind compilation-mode-map
           "M-<" #'beginning-of-buffer
           "M->" #'end-of-buffer
           "<" #'scroll-down-command
           ">" #'scroll-up-command)))

(defun rps-display-buffer-compilation-mode-p (buffer-name action)
  "Determine whether BUFFER-NAME is a compilation buffer."
  (with-current-buffer buffer-name
    (eq 'compilation-mode (buffer-local-value 'major-mode (current-buffer)))))

(defun rps-compilation-colorize ()
  (with-silent-modifications
    (ansi-color-apply-on-region compilation-filter-start (point))))

