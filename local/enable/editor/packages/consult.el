;;; consult.el -*- lexical-binding: t; -*-

(setup consult
  ;;TODO: add open externally THIS file
  (:bind
    (:bind @keymap-leader
	   "R" #'consult-complex-command)
    (@keymap-search
     "s" #'consult-line
     "S" #'consult-line-multi
     "G" #'consult-git-grep
     "L" #'consult-focus-lines)
    (@keymap-file
     "e" #'consult-file-externally)
    (@keymap-toggle
     "t" #'consult-theme)
    (:global-map
     [remap switch-to-buffer] #'consult-buffer
     [remap project-switch-to-buffer] #'consult-project-buffer
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
     [remap find-name-dired] #'consult-fd
     [remap find-grep-dired] #'consult-ripgrep
     [remap info] #'consult-info)
    (help-map
     "a" #'consult-apropos                ;BUG: remapping above doesn't work
     "M" #'consult-man))

  (:option consult-project-root-function (lambda ()
					   (when-let (project (project-current))
					     (car (project-roots project))))
	   consult-line-numbers-widen t
	   consult-narrow-key "<"
	   consult-async-min-input 2
	   consult-async-refresh-delay 0.15
	   consult-async-input-throttle 0.2
	   consult-async-input-debounce 0.1
	   
	   register-preview-delay 0
           register-preview-function #'consult-register-format
	   
	   xref-show-xrefs-function #'consult-xref
           xref-show-definitions-function #'consult-xref)

  (:with-function register-preview (:advice :override #'consult-register-window))

  
  (:with-feature meow
    (:when-loaded
      (:bind meow-normal-state-keymap
	     (:prefix "M-"
	       "z" #'consult-kmacro
	       "`" #'consult-register
	       "g" #'consult-goto-line
	       "m" #'consult-mark
	       "M" #'consult-global-mark
	       "o" #'consult-outline
	       "i" #'consult-imenu
	       "I" #'consult-imenu-multi
	       "!" #'consult-compile-error)
	     "`" #'consult-register-load
	     "~" #'consult-register-store
	     "!" #'consult-flymake)))

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
  
  (autoload #'consult--read "consult")
  (advice-add #'consult--read :around #'immediate-which-key-for-narrow)

  :extend (eshell)
  ;; consult-outline support
  (add-hook 'eshell-mode-hook (lambda () (setq outline-regexp eshell-prompt-regexp)))

  :extend (org)
  (bind org-mode-map
	(bind-local
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
                 args))))

(use-package embark-consult
  :after (embark consult))

;; bug: pulls in project and project pulls in xref and I think it is a bug to autoload define-key bindings because if this is loaded after user configurations, they may override the user bindings. which did mine for embark, so I load consult before embark
(use-package consult-project-extra
  :attach (rps/editor/workspace)
  (advice-add #'consult-project-extra--file
	      :before
	      (defun tab-set-name-for-project (project-root)
		(tab-new-to)
		(tab-rename
		 (file-name-nondirectory
		  (string-trim-right project-root "/")))))
  
  :attach (rps/editor/project)
  (bind rps/leader-map
	"p" #'consult-project-extra-find
	"P" project-prefix-map)
  
  :init
  (defun project-dispatch ()
    (interactive)
    (if-let ((project (project-current)))
	(project-switch-project (project-root project))
      (message "Not in a project."))))

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
