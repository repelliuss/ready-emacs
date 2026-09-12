;;; ace-window.el -*- lexical-binding: t; -*-

(cfg-pkg ace-window
  (:bind rps-keymap-leader
         (:autoload 'ace-window
           "w" #'rps-aw-hasty
           "W" #'aw-flip-window))
  (:opt aw-keys '(?q ?e ?r ?u ?i ?o)
        aw-scope 'frame
		aw-minibuffer-flag t
        aw-dispatch-always t
        aw-fair-aspect-ratio 3
        aw-dispatch-alist '((?k aw-delete-window "Kill")
                            (?s aw-swap-window "Swap")
                            (?m aw-move-window "Move")
                            (?v rps-aw-split-horz)
                            (?h rps-aw-split-vert)
                            (?c rps-aw-copy-or-clone)
                            (?d rps-aw-delete-current)
                            (?D rps-aw-delete-others)
                            (?p rps-aw-split-fair-switch-buffer)
                            (?P rps-aw-split-fair)
                            (?w rps-aw-next)
                            (?l maximize-window)
                            (?= balance-windows)
							(?> rotate-windows)
                            (?< window-layout-rotate-clockwise)
                            (?? rps-aw-show-dispatch-help)))
  (:face aw-leading-char-face (:foreground "white" :background "purple" :weight 'bold :height 3.5))
  (:advice-to #'aw-split-window-vert :after #'windmove-down)
  (:advice-to #'aw-split-window-horz :after #'windmove-right)
  (:advice-to #'avy-read :around #'rps-avy-read-smart))

(defun rps-aw-hasty ()
  "Invoke `ace-window' silently."
  (interactive)
  (let ((inhibit-message t))
    (ace-window 0)))

(defun rps-avy-read-smart (avy-read-fn &rest args)
  "When there are exactly 2 windows, dispatch immediately without avy overlay."
  (if (not (and (eq real-this-command #'rps-aw-hasty)
                (= (count-windows) 2)))
      (apply avy-read-fn args)
    (catch 'done
      (setq aw-action (aw-dispatch-default (read-char)))
      (cons 0 (next-window)))))

(defun rps-aw-split-horz ()
  "Split window horizontally."
  (split-window-horizontally))

(defun rps-aw-split-vert ()
  "Split window vertically."
  (split-window-vertically))

(defun rps-aw-delete-current ()
  "Delete current window and clean up ace-window state."
  (assoc-delete-all (selected-window) aw--windows-points)
  (delete-window))

(defun rps-aw-copy-or-clone ()
  "Copy buffer to another window, or clone if only one window."
  (pcase (length (window-list))
    (1 (rps-aw-split-fair))
    (2 (aw-copy-window (next-window)))
    (_ (run-at-time nil nil
                    #'aw-select "Ace- Select a window to copy current buffer" #'aw-copy-window))))

(defun rps-aw-delete-others ()
  "Delete all other windows, keeping only current."
  (setq aw--windows-points (list (assoc (selected-window) aw--windows-points)))
  (delete-other-windows))

(defun rps-aw-split-fair-switch-buffer ()
  "Split window fairly and switch buffer in the new window."
  (select-window (aw-split-window-fair (selected-window)))
  (call-interactively (cond
					   ((fboundp #'consult-projectile) #'consult-projectile)
                       ((fboundp #'consult-buffer) #'consult-buffer)
                       (t #'switch-to-buffer))))

(defun rps-aw-split-fair ()
  "Split current window fairly."
  (aw-split-window-fair (selected-window)))

(defun rps-aw-next ()
  "Switch to next window."
  (other-window 1))

(defun rps-aw-show-dispatch-help ()
  "Force display of ace-window dispatch help."
  (let ((inhibit-message nil))
    (aw-show-dispatch-help)))
