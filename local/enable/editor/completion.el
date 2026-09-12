;;; completion.el -*- lexical-binding: t; -*-

(cfg emacs
  (:opt tab-always-indent 'complete
        text-mode-ispell-word-completion nil
        read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t
        dabbrev-case-fold-search nil)

  (:after dabbrev
    (:prepend* dabbrev-ignored-buffer-regexps '("\\` ")
			   dabbrev-ignored-buffer-modes '(authinfo-mode
                                              doc-view-mode
                                              pdf-view-mode
                                              tags-table-mode))))

(cfg completion-preview
  (global-completion-preview-mode 1)
  (:after-this
	(:bind completion-preview-active-mode-map
           "M-i" nil
           "TAB" #'completion-preview-insert
           "M-c M-c" #'completion-preview-complete)))
