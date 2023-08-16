;;; meow.el -*- lexical-binding: t; -*-

;; TODO: move these functions to proper places and bind them there

(defun project-aware-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-shell-command)
    (call-interactively #'shell-command)))

(defun project-aware-async-shell-command ()
  (interactive)
  (run-at-time nil nil #'previous-history-element 1)
  (if-let ((project (project-current)))
      (call-interactively #'project-async-shell-command)
    (call-interactively #'async-shell-command)))

(setup meow
  (:require meow)
  (:bind
    (meow-keymap [remap describe-key] nil)		; fixes describe-key in insert-mode
    
    (meow-motion-state-keymap
     "I" #'meow-temp-normal)
    
    (meow-insert-state-keymap
     "M-i" #'meow-insert-exit
     "SPC" #'self-insert-command
     "C-SPC" @leader-map)
    
    (@leader-map
     "1" #'meow-digit-argument
     "2" #'meow-digit-argument
     "3" #'meow-digit-argument
     "4" #'meow-digit-argument
     "5" #'meow-digit-argument
     "6" #'meow-digit-argument
     "7" #'meow-digit-argument
     "8" #'meow-digit-argument
     "9" #'meow-digit-argument
     "0" #'meow-digit-argument
     "u" #'universal-argument
     "." #'find-file
     "," #'switch-to-buffer)
    
    ((setq meow-normal-state-keymap @normal-map)
     @leader-prefix @leader-map
     "0" #'meow-expand-0
     "9" #'meow-expand-9
     "8" #'meow-expand-8
     "7" #'meow-expand-7
     "6" #'meow-expand-6
     "5" #'meow-expand-5
     "4" #'meow-expand-4
     "3" #'meow-expand-3
     "2" #'meow-expand-2
     "1" #'meow-expand-1
     ";" #'meow-reverse
     "," #'meow-inner-of-thing
     "." #'meow-bounds-of-thing
     "[" #'meow-beginning-of-thing
     "]" #'meow-end-of-thing
     "b" #'meow-back-symbol
     "B" #'meow-back-word
     "c" #'meow-change
     "C" #'meow-comment
     "w" #'meow-next-symbol
     "W" #'meow-next-word
     "f" #'meow-find
     "F" #'meow-find-expand
     "g" #'meow-cancel
     "G" #'meow-grab
     "h" #'meow-left
     "H" #'meow-left-expand
     "i" #'meow-insert
     "I" #'meow-insert
     "o" #'meow-open-below
     "O" #'meow-open-above
     "j" #'meow-next
     "J" #'meow-next-expand
     "k" #'meow-prev
     "K" #'meow-prev-expand
     "l" #'meow-right
     "L" #'meow-right-expand
     "M-j" #'meow-join
     "n" #'meow-search
     "N" #'meow-pop-search
     "e" #'meow-block
     "E" #'meow-to-block
     "y" #'meow-yank
     "Y" #'meow-yank-pop
     "M-g" #'meow-goto-line
     "r" #'meow-replace-save
     "R" #'meow-swap-grab
     "d" #'meow-kill
     "D" #'meow-kill-whole-line
     "t" #'meow-till
     "T" #'meow-till-expand
     "<" #'scroll-down-command
     ">" #'scroll-up-command
     "C->" #'scroll-other-window
     "C-<" #'scroll-other-window-down
     "u" #'meow-undo
     "U" #'undo-redo
     "M-u" #'meow-undo-in-selection
     "v" #'isearch-forward
     "V" #'meow-visit
     "q" #'meow-start-kmacro-or-insert-counter
     "Q" #'meow-end-or-call-kmacro
     "z" #'meow-kmacro-matches
     "Z" #'meow-kmacro-lines
     "m" #'meow-mark-symbol
     "M" #'meow-mark-word
     "x" #'meow-line
     "X" #'meow-line-expand
     "s" #'meow-save
     "S" #'meow-sync-grab
     "p" #'meow-pop-selection
     "P" #'meow-pop-all-selection
     "%" #'meow-query-replace-regexp
     "M-%" #'meow-query-replace
     "/" #'repeat
     "'" #'negative-argument
     "=" #'meow-indent
     "\\" #'quoted-insert
     "$" #'project-aware-shell-command
     "&" #'project-aware-async-shell-command
     "RET" #'@press-thing-at-point)

    (mode-specific-map			; remove meow_dispatch* function appearing from C-c prefix
     "SPC" nil))

  (:option meow--kbd-undo "C-x u"		; REVIEW: do I really change the binding?
	   meow-use-clipboard t
	   meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
	   meow-keypad-meta-prefix nil
	   meow-keypad-ctrl-meta-prefix nil

	   ;; Make Meow use our leader keymap
	   ;; Only leader map is capable of being changed this way(?)
	   ;; https://github.com/meow-edit/meow/discussions/190#discussioncomment-2095009
	   (prepend meow-keymap-alist) (cons 'leader @leader-map)

	   (remove minor-mode-map-alist) (cons 'meow-normal-mode (alist-get 'meow-normal-mode minor-mode-map-alist))
	   (prepend minor-mode-map-alist) (cons 'meow-normal-mode @normal-map))
  
  ;; We modified meow-normal-state-keymap
  (set-keymap-parent meow-beacon-state-keymap @normal-map)
  
  (@funcall-consider-daemon #'meow-global-mode)

  (:with-function meow-insert
    (:advice :override (defun @meow-insert-at-point ()
			 "Switch to INSERT state."
			 (interactive)
			 (if meow--temp-normal
			     (progn
			       (message "Quit temporary normal mode")
			       (meow--switch-state 'motion))
			   (meow--cancel-selection)
			   (meow--switch-state 'insert)))))

  (:with-feature embark
    (:when-loaded
      (:with-function (embark-act embark-dwim)
	(:advice :before (defun @meow-cancel-selection-noerr (&rest _)
			   (ignore-errors (meow-cancel-selection)))))))

  (:with-feature org-capture
    (:when-loaded
      (:hook #'meow-insert)
      (:with-hook completion-in-region-mode-hook
	(:hook #'meow-insert))))

  (:with-feature which-key
    (:when-loaded
      (:option (prepend* which-key-replacement-alist) '(((nil . "^meow-") . (nil . ""))
							(("0" . "meow-digit-argument") . ("[0-9]"))
							(("[1-9]" . "meow-digit-argument") . t))))))
