;;; consult.el -*- lexical-binding: t; -*-

(use-package consult
  :attach (meow)
  (bind meow-normal-state-keymap
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

  :attach (rps/editor/search)
  (bind rps/search-map
	"s" #'consult-line
	"S" #'consult-line-multi
	"G" #'consult-git-grep
	"L" #'consult-focus-lines)

  ;;TODO: add open externally THIS file
  :attach (rps/editor/file)
  (bind rps/file-map
	"e" #'consult-file-externally)

  :attach (rps/editor/toggle)
  (bind rps/toggle-map
	"t" #'consult-theme)

  :init
  (bind
   ((current-global-map)
    [remap switch-to-buffer] #'consult-buffer
    [remap switch-to-buffer-other-window] #'consult-buffer-other-window
    [remap switch-to-buffer-other-frame] #'consult-buffer-other-frame
    [remap recentf-open-files] #'consult-recent-file
    [remap bookmark-jump] #'consult-bookmark
    [remap yank-pop] #'consult-yank-pop
    [remap view-register] #'consult-register ; BUG: preview buffer wrongly placed at first time
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
    "a" #'consult-apropos                ;BUG: remapping above doesn't work
    "M" #'consult-man))
  
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (autoload #'consult--read "consult")

  :config
  (setq consult-project-root-function (lambda ()
                                        (when-let (project (project-current))
                                          (car (project-roots project))))
        consult-line-numbers-widen t
	consult-narrow-key "<"
        consult-async-min-input 2
        consult-async-refresh-delay 0.15
        consult-async-input-throttle 0.2
        consult-async-input-debounce 0.1)

  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file
   :preview-key (kbd "M-P"))

  (consult-customize
   consult-theme
   :preview-key (list :debounce 0.5 'any))

  :extend (orderless)
  (defun consult--orderless-regexp-compiler (input type &rest _config)
    (setq input (orderless-pattern-compiler input))
    (cons
     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
     (lambda (str) (orderless--highlight input str))))

  (setq consult--regexp-compiler #'consult--orderless-regexp-compiler)

  (defun consult--without-orderless (&rest args)
    (minibuffer-with-setup-hook
	(lambda ()
          (setq-local consult--regexp-compiler #'consult--default-regexp-compiler))
      (apply args)))
  
  (advice-add #'consult-locate :around #'consult--without-orderless)

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
  ;; consult-outline support
  (add-hook 'eshell-mode-hook (lambda () (setq outline-regexp eshell-prompt-regexp)))

  :extend (org)
  (bind org-mode-map
	(bind-prefix (keys-make-local-prefix)
	  "." #'consult-org-heading))
  
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
                 args)))
  )

(use-package embark-consult
  :after (embark consult))

(use-package consult-project-extra
  :after (consult)
  :init
  (bind rps/leader-map
	"p" #'consult-project-extra-find))

;; TODO: integrate fd and rg
;; TODO: check fd in doom and also for consult
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
