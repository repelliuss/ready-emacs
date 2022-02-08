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
   '("." . find-file)
   '("," . switch-to-buffer)
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
   '("a" . meow-insert)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("C" . meow-comment)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("f" . meow-find)
   '("F" . meow-find-expand)
   '("g" . meow-cancel)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-append)
   '("o" . meow-open-below)
   '("O" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("M-j" . meow-join)
   '("n" . meow-search)
   '("N" . meow-pop-search)
   '("e" . meow-block)
   '("E" . meow-to-block)
   '("y" . meow-clipboard-yank)
   '("Y" . meow-yank-pop)
   '("M-g" . meow-goto-line)
   '("r" . meow-replace-save)
   '("R" . meow-swap-grab)
   '("d" . meow-clipboard-kill)
   '("D" . meow-kill-whole-line)
   '("t" . meow-till)
   '("T" . meow-till-expand)
   '("<" . scroll-down-command)
   '(">" . scroll-up-command)
   '("C->" . scroll-other-window)
   '("C-<" . scroll-other-window-down)
   '("u" . meow-undo)
   '("U" . undo-redo)
   '("M-u" . meow-undo-in-selection)
   '("v" . isearch-forward)
   '("V" . meow-visit)
   '("q" . meow-start-kmacro-or-insert-counter)
   '("Q" . meow-end-or-call-kmacro)
   '("z" . meow-kmacro-matches)
   '("Z" . meow-kmacro-lines)
   '("m" . meow-mark-word)
   '("M" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-line-expand)
   '("s" . meow-clipboard-save)
   '("S" . meow-sync-grab)
   '("p" . meow-pop-selection)
   '("P" . meow-pop-all-selection)
   '("%" . meow-query-replace-regexp)
   '("M-%" . meow-query-replace)
   '("/" . repeat)
   '("'" . negative-argument)
   '("=" . meow-indent)
   '("\\" . quoted-insert)
   '("$" . shell-command)
   '("&" . async-shell-command)))

(use-package meow
  :demand t
  :general
  (meow-insert-state-keymap
   "C-g" #'meow-insert-exit
   "<backspace>" #'backward-kill-word)

  :config
  (defvar rps/leader-map (make-sparse-keymap))
  
  (setq meow--kbd-undo "C-x u")
  
  (general-def "C-/" rps/leader-map)

  (add-to-list 'meow-keymap-alist (cons 'leader rps/leader-map))
  
  (meow-setup)
  (meow-global-mode 1)

  :extend (eshell)
  (add-hook 'eshell-mode-hook #'meow-insert-mode)

  :extend (corfu)
  (add-hook 'completion-in-region-mode-hook #'meow-insert)
  
  :extend (which-key)
  (add-to-list 'which-key-replacement-alist '((nil . "^meow-") . (nil . "")))
  (add-to-list 'which-key-replacement-alist '(("0" . "meow-digit-argument") . ("[0-9]")))
  (add-to-list 'which-key-replacement-alist '(("[1-9]" . "meow-digit-argument") . t))

  :extend (rps/editor/window)

  (general-def rps/leader-map
    "" rps/window-map)
  ;; :extend (rps/editor/file)
  ;; (set-keymap-parent meow-leader-keymap
  ;;                    (make-composed-keymap (keymap-parent meow-leader-keymap)
  ;;                                          rps/file-map))
  ;; :extend (rps/editor/open)
  ;; (set-keymap-parent meow-leader-keymap
  ;;                    (make-composed-keymap (keymap-parent meow-leader-keymap)
  ;;                                          rps/open-map))
  ;; :extend (rps/editor/buffer)
  ;; (set-keymap-parent meow-leader-keymap
  ;;                    (make-composed-keymap (keymap-parent meow-leader-keymap)
  ;;                                          rps/buffer-map))
  ;; :extend (rps/editor/search)
  ;; (set-keymap-parent meow-leader-keymap
  ;;                    (make-composed-keymap (keymap-parent meow-leader-keymap)
  ;;                                          rps/search-map))
  )

;; TODO: Set keypad window height here
