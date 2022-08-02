;;; php.el -*- lexical-binding: t; -*-

(defun php-extras-attach-lsp-completion ()
  (add-hook 'completion-at-point-functions
	    #'php-extras-completion-at-point
	    -1 'local))

(defun php-extras-detach-lsp-completion ()
  (remove-hook 'completion-at-point-functions
	       #'php-extras-completion-at-point 'local))

(define-minor-mode @php-extras-completion-lsp-integration-mode
  "Enable lsp completion integration with php-extras provided completions.

This will prioritize completions provided by php-extras package over lsp
provided completions.

Supports all.
Needed by lsp-mode."
  :lighter " @php-extras-cmplt-lsp"
  (if @php-extras-completion-lsp-integration-mode
      (php-extras-attach-lsp-completion)
    (php-extras-detach-lsp-completion)))

(defun php-extras-eldoc-lsp-mode (old-timer)
  (if (and (eq major-mode 'php-mode)
	   (or (null lsp--eldoc-saved-message)
	       (string-empty-p lsp--eldoc-saved-message)))
      (let ((doc (php-extras-eldoc-documentation-function)))
	(when doc
	  (cancel-timer old-timer)
	  (lsp--eldoc-message doc)))))

(defun php-extras-eldoc-attach-lsp-mode ()
  (advice-add #'lsp--eldoc-message :filter-return #'php-extras-eldoc-lsp-mode))

(defun php-extras-eldoc-detach-lsp-mode ()
  (advice-remove #'lsp--eldoc-message #'php-extras-eldoc-lsp-mode))

(define-minor-mode @php-extras-eldoc-lsp-integration-mode
  "Enable lsp eldoc integration with php-extras provided documentations.

Eldoc will try to fallback to php-extras provided documentation in case of there is no documentation provided by lsp.

Supports lsp-mode.
Needed by lsp-mode.

BUG: lsp-mode: Only works if lsp server successfully replies to lsp-hover
function."
  :lighter " @php-extras-eldoc-lsp"
  (if @php-extras-eldoc-lsp-integration-mode
      (if (featurep 'lsp-mode)
	  (php-extras-eldoc-attach-lsp-mode)
	(display-warning '@php-extras-eldoc-lsp-integration-mode
			 "lsp-mode should be loaded first! Maybe hook to lsp-mode-hook?")
	(setq @php-extras-eldoc-lsp-integration-mode nil))
    (php-extras-eldoc-detach-lsp-mode)))

(defun php-extras-load-eldoc-no-warn ()
  (require 'php-extras-eldoc-functions php-extras-eldoc-functions-file t))

(defun php-extras-generate-eldoc-async ()
  ;; Make expensive php-extras generation async
  (unless (file-exists-p (concat php-extras-eldoc-functions-file ".el"))
    (message "Generating PHP eldoc files...")
    (use-package async :demand t)
    (async-start `(lambda ()
                    ,(async-inject-variables "\\`\\(load-path\\|php-extras-eldoc-functions-file\\)$")
                    (require 'php-extras-gen-eldoc)
                    (php-extras-generate-eldoc-1 t))
                 (lambda (_)
                   (load (concat php-extras-eldoc-functions-file ".el"))
                   (message "PHP eldoc updated!")))))

(use-package php-extras
  :straight (:host github :repo "arnested/php-extras")
  :config
  (setq php-extras-eldoc-functions-file
	(concat cache-dir "php-extras-eldoc-functions"))
  (advice-add #'php-extras-load-eldoc :override #'php-extras-eldoc-no-warn)
  (php-extras-generate-eldoc-async))

(defvar phpunit-invoked-compilation nil)
(defvar phpunit-hide-compilation-buffer-is-reset t)

;; NOTE: we need this fix because 'compilation-finish-functions doesn't
;; work with a buffer local value assigned. So we clear ourselves afterwards 
(defun phpunit--hide-compilation-buffer-if-all-tests-pass-fix (buffer status)
  (if (and phpunit-invoked-compilation
	   phpunit-hide-compilation-buffer-if-all-tests-pass)
      (phpunit--hide-compilation-buffer-if-all-tests-pass buffer status)
    (remove-hook 'compilation-finish-functions
		 #'phpunit--hide-compilation-buffer-if-all-tests-pass-fix)
    (setq phpunit-hide-compilation-buffer-is-reset t))
  (setq phpunit-invoked-compilation nil))

(defun phpunit-set-invoked-compilation (cmd &rest args)
  (setq phpunit-invoked-compilation t)
  ;; NOTE: this is required here because we may be removed in another buffer
  (if phpunit-hide-compilation-buffer-is-reset
      (phpunit-setup-hide-compilation-buffer-if-all-tests-pass))
  (apply cmd args))

(dolist (cmd '(phpunit-current-test
	       phpunit-current-class
	       phpunit-current-project))
  (advice-add cmd :around #'phpunit-set-invoked-compilation))

(defun phpunit-setup-hide-compilation-buffer-if-all-tests-pass ()
  (when phpunit-hide-compilation-buffer-if-all-tests-pass
    (add-hook 'compilation-finish-functions
	      #'phpunit--hide-compilation-buffer-if-all-tests-pass-fix)
    (setq phpunit-hide-compilation-buffer-is-reset nil)))

(bind (setq phpunit-mode-map (make-sparse-keymap))
      (bind-prefix (keys-make-local-prefix "t")
	"t" #'phpunit-current-test
	"c" #'phpunit-current-class
	"p" #'phpunit-current-project
	"g" #'phpunit-group))

(define-minor-mode phpunit-mode
  "PHPUnit minor mode"
  :lighter " phpunit")

;; TODO: this function and below hook can be deleted when this mode moved
;; to its own file
(defun phpunit-mode-require-phpunit ()
  (require 'phpunit)
  (remove-hook 'phpunit-mode-hook #'phpunit-mode-require-phpunit))

(add-hook 'phpunit-mode-hook #'phpunit-mode-require-phpunit -1)

(use-package phpunit
  :attach (php-mode)
  (add-hook 'php-mode-hook #'phpunit-mode)
  
  :config
  (setq phpunit-colorize 'auto
	phpunit-hide-compilation-buffer-if-all-tests-pass t))

;; NOTE: php-mode warns about function already compiled, can be ignored
(use-package php-mode
  :init
  ;; not autoloaded in php-mode
  ;; EMACS: Needs to be upstreamed
  (defcustom php-mode-hook nil
    "List of functions to be executed on entry to `php-mode'."
    :group 'php-mode
    :tag "PHP Mode Hook"
    :type 'hook)

  :config
  (add-hook 'php-mode-hook (lambda ()
			     (setq-local electric-pair-inhibit-predicate
					 #'electric-pair-default-inhibit))))
