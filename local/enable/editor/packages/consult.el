;;; consult.el -*- lexical-binding: t; -*-

(setup consult
  ;;TODO: add open externally THIS file
  (:bind
    (@keymap-leader "R" #'consult-complex-command)
    (@keymap-search
     "s" #'consult-line
     "S" #'consult-line-multi
     "G" #'consult-git-grep
     "L" #'consult-focus-lines)
    (@keymap-file "e" #'consult-file-externally)
    (@keymap-toggle "t" #'consult-theme)
    ((:global-map)
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

  (:when-loaded
    (consult-customize
     consult-ripgrep consult-git-grep consult-grep
     consult-bookmark consult-recent-file
     :preview-key "M-P")

    (consult-customize
     consult-theme
     :preview-key (list :debounce 0.5 'any)))

  (:after-feature meow
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
	   "!" #'consult-flymake))

  (:after-feature orderless
    (:option consult--regexp-compiler #'@consult--orderless-regexp-compiler
	     (prepend orderless-style-dispatchers) #'@consult--orderless-dollar-dispatcher)

    (defun @consult--orderless-regexp-compiler (input type &rest _config)
      (setq input (orderless-pattern-compiler input))
      (cons
       (mapcar (lambda (r) (consult--convert-regexp r type)) input)
       (lambda (str) (orderless--highlight input str))))

    (defun @consult--orderless-suffix ()
      "Regexp which matches the end of string with Consult tofu support."
      (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
          (format "[%c-%c]*$"
                  consult--tofu-char
                  (+ consult--tofu-char consult--tofu-range -1))
	"$"))

    (defun @consult--orderless-dollar-dispatcher (pattern _index _total)
      ;; Ensure $ works with Consult commands, which add disambiguation suffixes
      (if (string-suffix-p "$" pattern)
	  `(orderless-regexp . ,(concat (substring pattern 0 -1) (@consult--orderless-suffix))))))

  (:after-feature which-key
    (defun @consult--which-key-immediate-narrow (fun &rest args)
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
    
    (:autoload consult--read)
    (:with-function consult--read (:advice :around #'@consult--which-key-immediate-narrow)))
  

  (:after-feature eshell
    (:with-hook eshell-mode-hook
      (:hook (defun @consult--eshell-outline-handler () (setq outline-regexp eshell-prompt-regexp)))))

  (:after-feature org
    (:bind org-mode-map (@bind-local "." #'consult-org-heading))
    (:option (append consult-buffer-sources) `(:name "Org"
						     :narrow ?o
						     :hidden t
						     :category buffer
						     :state ,#'consult--buffer-state
						     :items ,(lambda () (mapcar #'buffer-name (org-buffer-list))))))
  
  (:after-feature meow
    (:with-function consult-goto-line
      (:advice :after
	  (defun @consult--meow-goto-line-handler (&optional _arg)
	    (meow-line 1))))))

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
