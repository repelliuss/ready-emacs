;;; consult.el -*- lexical-binding: t; -*-

(cfg-pkg consult
  (:bind
    (rps-keymap-leader "R" #'consult-complex-command)
    (rps-keymap-search
     "s" #'consult-line
     "f" #'consult-fd
     "g" #'consult-ripgrep
     "S" #'consult-line-multi
     "G" #'consult-git-grep
     "L" #'consult-focus-lines)
    (rps-keymap-toggle "t" #'consult-theme)
    ((:global-map)
     [remap switch-to-buffer] #'consult-buffer
     [remap project-switch-to-buffer] #'consult-project-buffer
     [remap switch-to-buffer-other-window] #'consult-buffer-other-window
     [remap switch-to-buffer-other-frame] #'consult-buffer-other-frame
     [remap recentf-open-files] #'consult-recent-file
     [remap bookmark-jump] #'consult-bookmark
     [remap yank-pop] #'consult-yank-pop
     [remap view-register] #'consult-register
     [remap goto-line] #'consult-goto-line
     [remap pop-global-mark] #'consult-global-mark
     [remap imenu] #'consult-imenu
     [remap locate] #'consult-locate
     [remap load-theme] #'consult-theme
     [remap man] #'consult-man
     [remap keep-lines] #'consult-keep-lines
     [remap find-name-dired] #'consult-fd
     [remap find-grep-dired] #'consult-ripgrep
     [remap info] #'consult-info)
    (help-map "M" #'consult-man)
    (rps-keymap-normal
     "`" #'consult-register-load
     "~" #'consult-register-store
     (:prefix "M-"
       "z" #'consult-kmacro
       "`" #'consult-register
       "m" #'consult-mark
       "M" #'consult-global-mark
       "o" #'consult-outline
       "i" #'consult-imenu
       "I" #'consult-imenu-multi
       "!" #'consult-compile-error)))

  (:opt consult-line-numbers-widen t
        consult-narrow-key "<"
        consult-preview-key 'any
        consult-async-min-input 3
        consult-async-refresh-delay 0.2
        consult-async-input-throttle 0.5
        consult-async-input-debounce 0.2

        register-preview-delay 0.5
        register-preview-function #'consult-register-format

        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (:advice-to #'register-preview :override #'consult-register-window
			  #'consult--read :around #'rps-consult--show-narrow-keys-asap-with-which-key)

  ;; Safe automatic previews
  (:after-this
    (consult-customize
     consult-theme
     :preview-key (list :debounce 0.5 'any))

    (:after meow
      (:advice-to #'consult-goto-line :after #'rps-consult--meow-goto-line-fix-position)))

  (:after orderless
    (:opt orderless-style-dispatchers (list #'rps-orderless-consult-dispatch
                                            #'orderless-kwd-dispatch
                                            #'orderless-affix-dispatch)))

  (:after org
    (:bind org-mode-map
		   (:locally "." #'consult-org-heading))))

(defun rps-consult--show-narrow-keys-asap-with-which-key (fun &rest args)
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

(with-eval-after-load 'meow
  (defun rps-consult--meow-goto-line-fix-position (&optional _arg)
    (meow-line 1)))

(with-eval-after-load 'orderless
  ;; See @minad's orderless configuration https://github.com/minad/consult/wiki
  (defun rps-orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (boundp 'consult--tofu-regexp)
        (concat consult--tofu-regexp "*\\'")
      "\\'"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun rps-orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (rps-orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (rps-orderless--consult-suffix)))))))
