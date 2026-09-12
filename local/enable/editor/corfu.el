;;; corfu.el -*- lexical-binding: t; -*-

(cfg-pkg yasnippet-capf
  (:bind rps-keymap-completion
	     "M-s" #'yasnippet-capf))

(cfg-pkg cape
  (:bind (rps-keymap-completion
	      (:prefix "M-"
            "c" #'completion-at-point
            "t" #'complete-tag
	        "d" #'cape-dabbrev
            "e" #'cape-emoji
	        "f" #'cape-file
	        "k" #'cape-keyword
	        "a" #'cape-abbrev
	        "i" #'cape-ispell
	        "l" #'cape-line
	        "w" #'cape-dict
	        "\\" #'cape-tex
	        "&" #'cape-sgml
	        "r" #'cape-rfc1345))
         ((:global-map)
          "M-c" rps-keymap-completion))
  (:hook-to 'completion-at-point-functions #'cape-dabbrev)
  (:hook-to 'prog-mode #'rps-add-prog-mode-capfs))

(cfg-pkg corfu
  (global-corfu-mode 1)

  (:opt corfu-cycle t                   ; Enable cycling for `corfu-next/previous'
        corfu-scroll-margin 5           ; Use scroll margin
        corfu-quit-at-boundary 'separator
        corfu-quit-no-match nil
        corfu-on-exact-match 'insert
        corfu-preselect 'directory
        global-corfu-minibuffer (lambda ()
                                  (not (or (bound-and-true-p mct--active)
                                           (bound-and-true-p vertico--input)
                                           (eq (current-local-map) read-passwd-map))))
		)
  (:prepend corfu-continue-commands #'rps-corfu-move-to-minibuffer)

  (:bind (corfu-map
	      "SPC" #'corfu-insert-separator
          "M-m" #'rps-corfu-move-to-minibuffer
	      "M-j" #'corfu-next
	      "M-k" #'corfu-previous
	      "C-<" #'corfu-first
	      "C->" #'corfu-last
	      "M-<" #'corfu-scroll-down
	      "M->" #'corfu-scroll-up))

  (:after (cape yasnippet-capf)
    (:hook-to 'emacs-lisp-mode
      #'rps-corfu-emacs-lisp-mode-integration)

    (:after (orderless lsp-mode)
      (:opt lsp-completion-provider :none)
      (:hook-to 'lsp-completion-mode
        #'rps-corfu-lsp-mode-integration-for-orderless))

    (:after (orderless eglot)
      (:opt completion-category-overrides '((eglot (styles orderless))
                                            (eglot-capf (styles orderless)))
            completion-category-defaults nil)
      (:advice-to 'eglot-completion-at-point :around #'cape-wrap-buster))))

(cfg-pkg (:require kind-icon)
  (:opt svg-lib-icons-dir (concat rps-dir-cache "svg-lib/"))
  (:after corfu
    (:opt kind-icon-default-face 'corfu-default)
    (:prepend corfu-margin-formatters #'kind-icon-margin-formatter)))

(cfg-pkg (:elpaca corfu-history
                    :host github
                    :repo "minad/corfu"
                    :files ("extensions/corfu-history.el"))
  (:after savehist
    (:prepend savehist-additional-variables 'corfu-history))
  (corfu-history-mode 1))

(cfg-pkg (:elpaca corfu-quick
                    :host github
                    :repo "minad/corfu"
                    :files ("extensions/corfu-quick.el"))
  (:bind corfu-map
	     "M-a" #'corfu-quick-insert
	     "M-A" #'corfu-quick-complete))

(cfg-pkg (:elpaca corfu-info
                    :host github
                    :repo "minad/corfu"
                    :files ("extensions/corfu-info.el")))

(cfg-pkg (:elpaca corfu-popupinfo
                    :host github
                    :repo "minad/corfu"
                    :files ("extensions/corfu-popupinfo.el"))
  (:opt corfu-popupinfo-delay '(1.0 . 0.5))
  (corfu-popupinfo-mode 1)
  (:bind corfu-popupinfo-map
         "C-M-<" #'scroll-other-window-down
         "C-M->" #'scroll-other-window))

(defun rps-corfu-move-to-minibuffer ()
  (interactive)
  (pcase completion-in-region--data
    (`(,beg ,end ,table ,pred ,extras)
     (let ((completion-extra-properties extras)
           completion-cycle-threshold completion-cycling)
       (consult-completion-in-region beg end table pred)))))

(defun rps-add-prog-mode-capfs ()
  (add-hook 'completion-at-point-functions #'cape-file -1 'local))

(defun rps-corfu-emacs-lisp-mode-integration ()
  (add-hook 'completion-at-point-functions
            (cape-capf-super #'yasnippet-capf #'elisp-completion-at-point) 0 'local))

(defun rps-corfu-lsp-mode-integration-for-orderless ()
  (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
        '(orderless))
  (remove-hook 'completion-at-point-functions #'lsp-completion-at-point)
  (add-hook 'completion-at-point-functions
            (cape-capf-super #'cape-keyword #'yasnippet-capf (cape-capf-buster #'lsp-completion-at-point))
            90 'local))
