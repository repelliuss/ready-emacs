;;; meow.el -*- lexical-binding: t; -*-

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . meow-motion-origin-command)
   '("k" . meow-motion-origin-command)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change-save)
   '("C" . meow-comment)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("f" . meow-find)
   '("F" . meow-find-expand)
   '("g" . meow-cancel)
   '("G" . meow-grab)
   '("h" . meow-head)
   '("H" . meow-head-expand)
   '("i" . meow-insert)
   '("o" . meow-open-below)
   '("O" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-tail)
   '("L" . meow-tail-expand)
   '("M-j" . meow-join)
   '("n" . meow-search)
   '("N" . meow-pop-search)
   '("e" . meow-block)
   '("E" . meow-block-expand)
   '("p" . meow-clipboard-yank)
   '("P" . meow-yank-pop)
   '("M-g" . meow-goto-line)
   '("r" . meow-replace-save)
   '("R" . meow-swap-grab)
   '("d" . meow-clipboard-kill)
   '("D" . meow-C-d)
   '("t" . meow-till)
   '("T" . meow-till-expand)
   '("<" . scroll-down-command)
   '(">" . scroll-up-command)
   '("u" . meow-undo)
   '("U" . undo-redo)
   '("M-u" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("q" . meow-start-kmacro-or-insert-counter)
   '("Q" . meow-end-or-call-kmacro)
   '("z" . meow-kmacro-lines)
   '("Z" . meow-kmacro-matches)
   '("m" . meow-mark-word)
   '("M" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-line-expand)
   '("y" . meow-clipboard-save)
   '("Y" . meow-sync-grab)
   '("s" . meow-pop-selection)
   '("S" . meow-pop-all-selection)
   '("&" . meow-query-replace)
   '("%" . meow-query-replace-regexp)
   '("/" . repeat)
   '("'" . negative-argument)
   '("=" . meow-indent)
   '("\\" . quoted-insert)))

(use-package meow
  :demand t
  :general
  (:keymaps 'meow-leader-keymap
   "." #'find-file)
  (:keymaps 'meow-insert-state-keymap
   "C-g" #'meow-insert-exit)
  :config
  (after! which-key
    (add-to-list 'which-key-replacement-alist '((nil . "^meow-") . (nil . "")))
    (add-to-list 'which-key-replacement-alist '(("0" . "meow-digit-argument") . ("[0-9]")))
    (add-to-list 'which-key-replacement-alist '(("[1-9]" . "meow-digit-argument") . t)))
  (after! rdy/window/editor
    (set-keymap-parent meow-leader-keymap rdy/window-map))
  (meow-setup)
  (meow-global-mode))

;; TODO: Set keypad window height here