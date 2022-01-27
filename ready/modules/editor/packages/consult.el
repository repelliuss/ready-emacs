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
   [remap multi-occur] #'consult-multi-occur
   [remap imenu] #'consult-imenu
   [remap locate] #'consult-locate
   [remap load-theme] #'consult-theme
   [remap apropos] #'consult-apropos
   [remap man] #'consult-man
   [remap keep-lines] #'consult-keep-lines
   [remap find-name-dired] #'consult-find
   [remap find-grep-dired] #'consult-grep)

  (help-map
   "a" #'consult-apropos                ; BUG: remapping above doesn't work
   "M" #'consult-man)

  :attach (meow)
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
    "M-I" #'consult-imenu-multi
    "!" #'consult-flymake
    "M-!" #'consult-compile-error)

  :attach (ready/editor/search)
  (general-def ready/search-map
    :prefix "s"
    "s" #'consult-line
    "S" #'consult-line-multi
    "G" #'consult-git-grep
    "L" #'consult-focus-lines)

  ;; TODO: add open externally THIS file
  :attach (ready/editor/file)
  (general-def ready/file-map
    :prefix "f"
    "e" #'consult-file-externally)

  :init
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (recentf-mode 1)

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
   :preview-key (kbd "M-P"))

  (consult-customize
   consult-theme
   :preview-key (list (kbd "M-P") :debounce 0.5 'any))

  :extend (orderless)
  (defun consult--orderless-regexp-compiler (input type)
    (setq input (orderless-pattern-compiler input))
    (cons
     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
     (lambda (str) (orderless--highlight input str))))

  (setq consult--regexp-compiler #'consult--orderless-regexp-compiler)

  :extend (which-key)
  (defun immediate-which-key-for-narrow (fun &rest args)
    (let* ((refresh t)
           (timer (and consult-narrow-key
                       (memq :narrow args)
                       (run-at-time 0.05 0.05
                                    (lambda ()
                                      (if (eq last-input-event (elt consult-narrow-key 0))
                                          (when refresh
                                            (setq refresh nil)
                                            (which-key--update))
                                        (setq refresh t)))))))
      (unwind-protect
          (apply fun args)
        (when timer
          (cancel-timer timer)))))
  (advice-add #'consult--read :around #'immediate-which-key-for-narrow)

  :extend (eshell)
  (add-hook 'eshell-mode-hook (lambda () (setq outline-regexp eshell-prompt-regexp)))

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
  (advice-add #'consult-goto-line :after (lambda (&optional _arg) (meow-line 1)))

  :extend (vertico)
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args))))

(use-package embark-consult
  :after (embark consult))

;; TODO: integrate fd and rg
;; TODO: check fd in doom and also for consult
;; TODO: general-def keymaps remove
;; TODO: make a search map like window
;; TODO: integrate org mode, Miscellaneous
;; TODO: add preview to meow-visit
;; TODO: integrate embark
;; TODO: add flycheck support
;; TODO: add open externally to file map
;; TODO: add theme to something
;; TODO: what consult completion preview does for embark collect buffers
;; TODO: integrate which-key to search map
;; TODO: integrate extensions
