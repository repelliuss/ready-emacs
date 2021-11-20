;;; consult.el -*- lexical-binding: t; -*-

(use-package consult
  :general
  ([remap switch-to-buffer] #'consult-buffer
   [remap switch-to-buffer-other-window] #'consult-buffer-other-window
   [remap switch-to-buffer-other-frame] #'consult-buffer-other-frame
   [remap recentf-open-files] #'consult-recent-file
   [remap bookmark-jump] #'consult-bookmark
   [remap yank-pop] #'consult-yank-pop
   [remap view-register] #'consult-register
   [remap goto-line] #'consult-goto-line
   [remap pop-global-mark] #'consult-global-mark
   [remap imenu] #'consult-imenu
   [remap apropos] #'consult-apropos
   [remap locate] #'consult-locate
   [remap load-theme] #'consult-theme
   [remap man] #'consult-man)

  :init
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)
  (advice-add #'multi-occur :override #'consult-multi-occur)

  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)

  (recentf-mode 1)

  (with-eval-after-load 'meow
    (general-def meow-normal-state-keymap
      "M-z" #'consult-kmacro

      "`" #'consult-register-load
      "~" #'consult-register-store
      "M-`" #'consult-register

      "M-g" #'consult-goto-line

      "M-m" #'consult-mark
      "M-M" #'consult-global-mark

      "M-o" #'consult-outline

      "M-i" #'consult-imenu
      "M-I" #'consult-imenu-multi))

  (with-eval-after-load 'ready/editor/search
    (general-def ready/search-map
      :prefix "s"
      "s" #'consult-line
      "S" #'consult-line-multi

      "o" #'occur
      "O" #'consult-multi-occur

      "l" #'consult-keep-lines
      "L" #'consult-focus-lines

      "f" #'consult-find
      "F" #'consult-locate))

  :config
  (setq consult-project-root-function (lambda ()
                                        (when-let (project (project-current))
                                          (car (project-roots project))))
        consult-narrow-key "<"
        consult-widen-key ">"
        consult-line-numbers-widen t
        consult-async-min-input 2
        consult-async-refresh-delay 0.15
        consult-async-input-throttle 0.2
        consult-async-input-debounce 0.1)

  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file
   consult--source-file consult--source-project-file consult--source-bookmark
   :preview-key (kbd "C-SPC"))

  (consult-customize
   consult-theme
   :preview-key (list (kbd "C-SPC") :debounce 0.5 'any))

  :extend (org)
  (defvar consult--org-source
    `(:name "Org"
      :narrow ?o
      :hidden t
      :category buffer
      :state ,#'consult--buffer-state
      :items ,(lambda () (mapcar #'buffer-name (org-buffer-list)))))

  (add-to-list 'consult-buffer-sources 'consult--org-source 'append)

  :extend (meow)
  (advice-add #'consult-goto-line :after (lambda (&optional _arg) (meow-line 1))))

;; TODO: integrate fd and rg
;; TODO: check fd in doom and also for consult
;; TODO: general-def keymaps remove
;; TODO: make a search map like window
;; TODO: check xref and integrate
;; TODO: integrate compilation, org mode, Miscellaneous
;; TODO: add preview to meow-visit
;; TODO: integrate embark
