;;; ace-window-hasty-windows.el -*- lexical-binding: t; -*-

(use-package ace-window
  :commands (ace-window-hasty)

  :attach (meow)
  (general-def meow-leader-keymap
    "w" #'ace-window-hasty
    "W" #'aw-flip-window)

  :config
  (setq aw-minibuffer-flag t
        aw-dispatch-always t
        aw-fair-aspect-ratio 3
        aw-dispatch-alist '((?k aw-delete-window "Kill")
                            (?s aw-swap-window "Swap")
                            (?m aw-move-window "Move")
                            (?c aw-copy-window "Copy")
                            (?d aw--delete-current-window)
                            (?D aw--delete-other-windows)
                            (?p aw--split-current-window-fair-switch-buffer) ; pop window
                            (?P aw--split-current-window-fair) ; pop window
                            (?w aw--switch-to-next-window) ; will only work if there are 2 windows
                            (?l maximize-window)
                            (?= balance-windows)
                            (?? aw--force-show-dispatch-help)))

  (advice-add #'aw-split-window-vert :after #'windmove-down)
  (advice-add #'aw-split-window-horz :after #'windmove-right)
  (advice-add #'avy-read :around #'avy--read-smart)

  (defun ace-window-hasty ()
    (interactive)
    (let ((inhibit-message t))
      (ace-window 0)))

  (defun avy--read-smart (avy-read-fn &rest args)
    (if (not (and (eq real-this-command #'ace-window-hasty)
                  (= (count-windows) 2)))
        (apply avy-read-fn args)
      (catch 'done
        (setq aw-action (aw-dispatch-default (read-char)))
        (cons 0 (next-window)))))

  (defun aw--delete-current-window ()
    (assoc-delete-all (selected-window) aw--windows-points)
    (delete-window))

  (defun aw--delete-other-windows ()
    (setq aw--windows-points (list (assoc (selected-window) aw--windows-points)))
    (delete-other-windows))

  (defun aw--split-current-window-fair-switch-buffer ()
    (aw-split-window-fair (selected-window))
    (call-interactively (if (fboundp #'consult-buffer)
			    #'consult-buffer
			  #'switch-to-buffer)))

  (defun aw--split-current-window-fair ()
    (aw-split-window-fair (selected-window)))

  (defun aw--switch-to-next-window ()
    (other-window 1))

  (defun aw--force-show-dispatch-help ()
    (let ((inhibit-message nil))
      (aw-show-dispatch-help))))
