;;; meow.el -*- lexical-binding: t; -*-

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev))
  (meow-leader-define-key
   '("j" . "H-j")
   '("k" . "H-k")
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("u" . universal-argument)
   '("." . find-file)
   '("," . switch-to-buffer))
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
   '("I" . meow-insert)
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
   '("y" . meow-yank)
   '("Y" . meow-yank-pop)
   '("M-g" . meow-goto-line)
   '("r" . meow-replace-save)
   '("R" . meow-swap-grab)
   '("d" . meow-kill)
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
   '("s" . meow-save)
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
  :config
  (bind
   (meow-motion-state-keymap
    "C-j" #'meow-temp-normal)
   (meow-insert-state-keymap
    "C-j" #'meow-insert-exit
    "SPC" #'self-insert-command)
   (meow-normal-state-keymap
    "C-j" #'meow-insert
    "SPC" rps/leader-map)
   (rps/leader-map
    "c" (lambda ()
	  (interactive)
	  (meow-keypad-start-with "C-c"))
    "SPC" (lambda ()
	    (interactive)
	    (let ((overriden (key-binding (kbd "C-c SPC"))))
	      (if (fboundp overriden)
		  (funcall overriden))))))

  (setq meow--kbd-undo "C-x u"		
	meow-use-clipboard t)

  (setq meow-keypad-meta-prefix nil
	meow-keypad-ctrl-meta-prefix nil)
  
  (add-to-list 'meow-keymap-alist (cons 'leader rps/leader-map))

  (meow-setup)
  (funcall-consider-daemon #'meow-global-mode)

  (define-key meow-keymap [remap describe-key] nil)

  :extend (embark)
  (defun meow-cancel-noerr (&rest _)
    (ignore-errors (meow-cancel)))
  
  (dolist (fn '(embark-act
		embark-dwim))
    (advice-add fn :before #'meow-cancel-noerr))
  
  :extend (org-capture)
  (add-hook 'org-capture-mode-hook #'meow-insert)
  
  :extend (corfu)
  (add-hook 'completion-in-region-mode-hook #'meow-insert)
  
  :extend (which-key)
  (add-to-list 'which-key-replacement-alist '((nil . "^meow-") . (nil . "")))
  (add-to-list 'which-key-replacement-alist '(("0" . "meow-digit-argument") . ("[0-9]")))
  (add-to-list 'which-key-replacement-alist '(("[1-9]" . "meow-digit-argument") . t)))


(defun press-thing-at-point ()
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

(bind meow-normal-state-keymap
      "RET" #'press-thing-at-point)
