;;; border-window.el --- One-pixel border around windows -*- lexical-binding: t; -*-
;; Keywords: convenience, faces, frames
;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Commentary:
;; Draw a one-pixel border around Emacs windows using fringes and the header
;; line.  Enable per-buffer with `border-window-mode' or globally with
;; `global-border-window-mode'.
;;; Code:

(defvar-local border-window--remaps nil
  "Active face-remap cookies for the border.")

(defvar-local border-window--saved-header nil
  "Saved `header-line-format' before border activation.")

(defun border-window-enable-fringe (&optional buffer)
  (interactive)
  (set-window-fringes (get-buffer-window (or buffer (current-buffer))) 1 1 'outside-margins 'persistent))

(defun border-window--enable ()
  "Enable the border in the current buffer."
  (run-at-time 0.5 0
               (lambda ()
                 (let* ((had-header (and header-line-format (not (and (stringp header-line-format) (string= " " header-line-format)))))
                        (size 1))
                   (setq border-window--saved-header had-header)
                   (unless had-header
                     (setq-local header-line-format " "))
                   (mapc #'face-remap-remove-relative border-window--remaps)
                   (setq border-window--remaps
                         (list (face-remap-add-relative 'fringe `(:background ,(face-foreground 'default)))
                               (if had-header
                                   (face-remap-add-relative 'header-line-inactive `(:box (:line-width ,(cons size size))))
                                 (face-remap-add-relative 'header-line-inactive
                                                          `(:background ,(face-background 'default) :height 0.1 :underline (:color "black" :position t))))
                               (if had-header
                                   (face-remap-add-relative 'header-line-active `(:box (:line-width ,(cons size size))))
                                 (face-remap-add-relative 'header-line-active
                                                          `(:background ,(face-background 'default) :height 0.1 :underline (:color "black" :position t))))))
                   (border-window-enable-fringe (current-buffer))))))

(defun border-window--disable ()
  "Disable the border in the current buffer."
  (let ((win (or (get-buffer-window (current-buffer)) (selected-window))))
    (setq-local header-line-format border-window--saved-header)
    (mapc #'face-remap-remove-relative border-window--remaps)
    (setq border-window--remaps nil)
    (set-window-fringes win nil nil)))

;;;###autoload
(define-minor-mode border-window-mode
  "Toggle a one-pixel border around the current window."
  :lighter nil
  (if border-window-mode (border-window--enable) (border-window--disable)))

(defun border-window--maybe-enable ()
  "Enable `border-window-mode' unless in a minibuffer or internal buffer."
  (unless (minibufferp)
    (border-window-mode 1)))

;;;###autoload
(define-globalized-minor-mode global-border-window-mode
  border-window-mode border-window--maybe-enable
  :group 'border-window)

(provide 'border-window)
;;; border-window.el ends here

(global-border-window-mode 1)
