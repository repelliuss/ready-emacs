;;; meow.el -*- lexical-binding: t; -*-

(defun rps-press-thing-at-point ()
  (interactive)
  (let* ((field  (get-char-property (point) 'field))
         (button (get-char-property (point) 'button))
         (doc    (get-char-property (point) 'widget-doc))
         (widget (or field button doc)))
    (cond
     ((and widget
           (or (and (symbolp widget)
                    (get widget 'widget-type))
               (and (consp widget)
                    (get (widget-type widget) 'widget-type))))
      (widget-button-press (point)))
     ((and (button-at (point)))
      (push-button)))))

(defmacro rps-funcall-consider-daemon (fn)
  "Unless current session is daemon call FN, otherwise call it after first frame."
  (if (daemonp)
      `(cfg--add-hook-transient 'server-after-make-frame-hook ,fn)
    `(funcall ,fn)))

(defun rps-meow-insert-at-point ()
  "Switch to INSERT state."
  (interactive)
  (if meow--temp-normal
      (progn
        (message "Quit temporary normal mode")
        (meow--switch-state 'motion))
    (meow--cancel-selection)
    (meow--switch-state 'insert)))

(defun rps-meow-toggle-motion-mode ()
  (if meow-motion-mode
      (meow--switch-state 'normal t)
    (meow--switch-state 'motion)))

(defun rps-meow-insert-if-completion-active ()
  (when completion-in-region-mode
    (meow-insert)))

(cfg-pkg (:require meow)
  (:bind
    (meow-keymap [remap describe-key] nil)              ; fixes describe-key in insert-mode
    
    (meow-motion-state-keymap
     "I" #'meow-temp-normal)
    
    (meow-insert-state-keymap
     "M-i" #'meow-insert-exit
     "SPC" #'self-insert-command)
    
    (rps-keymap-leader
     "`" #'window-toggle-side-windows
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
    
    ((setq meow-normal-state-keymap rps-keymap-normal)
     rps-key-leader-prefix rps-keymap-leader
     ;; Expand selection by digit
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

     ;; Things (reverse / inner / bounds / beginning / end)
     ";" #'meow-reverse
     "," #'meow-inner-of-thing
     "." #'meow-bounds-of-thing
     "[" #'meow-beginning-of-thing
     "]" #'meow-end-of-thing

     ;; Movement by symbol/word, change, comment
     "b" #'meow-back-symbol
     "B" #'meow-back-word
     "c" #'meow-change
     "C" #'meow-comment
     "w" #'meow-next-symbol
     "W" #'meow-next-word

     ;; Find / cancel / grab
     "f" #'meow-find
     "F" #'meow-find-expand
     "g" #'meow-cancel
     "G" #'meow-grab

     ;; Directional movement, insert, open line
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

     ;; Search
     "n" #'meow-search
     "N" #'meow-pop-search

     ;; Block selection
     "e" #'meow-block
     "E" #'meow-to-block

     ;; Yank / kill ring
     "y" #'meow-yank
     "Y" #'meow-yank-pop
     "M-g" #'meow-goto-line

     ;; Replace
     "r" #'meow-replace
     "R" #'meow-swap-grab

     ;; Kill
     "d" #'meow-kill
     "D" #'meow-kill-whole-line

     ;; Till
     "t" #'meow-till
     "T" #'meow-till-expand

     ;; Scroll & other window
     "<" #'scroll-down-command
     ">" #'scroll-up-command
     "C->" #'scroll-other-window
     "C-<" #'scroll-other-window-down
     "C-M-<" #'beginning-of-buffer-other-window
     "C-M->" #'end-of-buffer-other-window

     ;; Undo
     "u" #'meow-undo
     "U" #'undo-redo
     "M-U" #'meow-undo-in-selection

     ;; Isearch / visit
     "v" #'isearch-forward
     "V" #'meow-visit

     ;; Keyboard macros
     "q" #'kmacro-start-macro-or-insert-counter
     "Q" #'meow-end-or-call-kmacro
     "z" #'meow-kmacro-matches
     "Z" #'meow-kmacro-lines

     ;; Mark
     "m" #'meow-mark-symbol
     "M" #'meow-mark-word

     ;; Line operations
     "x" #'meow-line
     "X" #'meow-line-expand

     ;; Save selection / sync grab
     "s" #'meow-save
     "S" #'meow-sync-grab

     ;; Selection stack
     "p" #'meow-pop-selection
     "P" #'meow-pop-all-selection

     ;; Query replace
     "%" #'meow-query-replace-regexp
     "M-%" #'meow-query-replace

     ;; Misc
     "/" #'repeat
     "'" #'negative-argument
     "=" #'meow-indent
     "\\" #'quoted-insert
     "RET" #'rps-press-thing-at-point)

    (mode-specific-map                  ; remove meow_dispatch* function appearing from C-c prefix
     "SPC" nil))

  (:opt meow--kbd-undo "C-x u"
        meow-use-clipboard t
        meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
        meow-keypad-meta-prefix nil
        meow-keypad-ctrl-meta-prefix nil)

  ;; Make Meow use our leader keymap
  ;; Only leader map is capable of being changed this way(?)
  ;; https://github.com/meow-edit/meow/discussions/190#discussioncomment-2095009
  (:prepend meow-keymap-alist (cons 'leader rps-keymap-leader))

  (:remove minor-mode-map-alist (cons 'meow-normal-mode (alist-get 'meow-normal-mode minor-mode-map-alist)))
  (:prepend minor-mode-map-alist (cons 'meow-normal-mode rps-keymap-normal))

  ;; We modified meow-normal-state-keymap inside previous :set
  (set-keymap-parent meow-beacon-state-keymap rps-keymap-normal)
  
  (rps-funcall-consider-daemon #'meow-global-mode)

  (:advice-to #'meow-insert :override #'rps-meow-insert-at-point)

  (:hook-to 'org-capture-mode #'meow-insert)
  
  (:hook-to 'completion-in-region-mode #'rps-meow-insert-if-completion-active)
  
  (:hook-to 'macrostep-mode #'rps-meow-toggle-motion-mode)

  (:after consult
    (:opt meow-goto-line-function #'consult-goto-line))

  (:after which-key
    (:prepend* which-key-replacement-alist '((("SPC$" . "prefix") . (nil . "local"))
                                             ((nil . "^meow-") . (nil . ""))
                                             (("[1-9]" . "digit-argument") . t)
                                             (("0" . "digit-argument") . ("[0-9]")))))

  (:after claude-code-ide
    (:prepend meow-mode-state-list '(eat-mode . insert)))
  
  (:after agent-shell
    (:prepend* meow-mode-state-list '((agent-shell-viewport-edit-mode . insert)))))
