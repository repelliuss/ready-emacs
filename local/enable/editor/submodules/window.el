;;; window.el -*- lexical-binding: t; -*-

;; (bind
;;  ((setq rps/window-map (make-sparse-keymap))
;;   "h" #'windmove-left
;;   "j" #'windmove-down
;;   "k" #'windmove-up
;;   "l" #'windmove-right
;;   "H" #'windmove-swap-states-left
;;   "J" #'windmove-swap-states-down
;;   "K" #'windmove-swap-states-up
;;   "L" #'windmove-swap-states-right
;;   "d" #'delete-window
;;   "D" #'delete-other-windows
;;   "s" #'split-window-below
;;   "v" #'split-window-right)
;;  (rps/leader-map
;;   "w" rps/window-map))

(setup which-key
  (:elpaca nil)
  (:when-loaded
    (:option (prepend* which-key-replacement-alist) '((("w$" . "prefix") . (nil . "window"))
						      (("w .$" . "\\(?:-\\(?:states\\|windows?\\)\\|wind\\(?:ow\\)?\\)") . (nil . ""))))))
