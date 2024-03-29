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

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("w$" . "prefix") . (nil . "window")))
  (add-to-list 'which-key-replacement-alist '(("w .$" . "\\(?:-\\(?:states\\|windows?\\)\\|wind\\(?:ow\\)?\\)") . (nil . ""))))
