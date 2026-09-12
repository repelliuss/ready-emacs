;;; enable-catalog.el --- Script browser for enable -*- lexical-binding: t; -*-

(require 'enable "enable.el")

(defvar enable-catalog-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "d") #'enable-catalog-disable)
    (define-key map (kbd "e") #'enable-catalog-enable)
    (define-key map (kbd "s") #'enable-catalog-save)
    (define-key map (kbd "f") #'enable-catalog-filter)
    (define-key map (kbd "F") #'enable-catalog-clear-filter)
    (define-key map (kbd "g") #'enable-catalog-refresh)
    (define-key map (kbd "RET") #'enable-catalog-visit)
    map))

(define-derived-mode enable-catalog-mode tabulated-list-mode "Enable-Catalog"
  "Browse and stage enable/disable changes to init scripts.

\\{enable-catalog-mode-map}"
  (setq tabulated-list-format [("Module" 10 t) ("Group" 10 t)
                                ("Script" 30 t) ("Status" 10 t) ("Notes" 0 nil)]
        tabulated-list-padding 2
        tabulated-list-sort-key (cons "Module" nil))
  (tabulated-list-init-header))

(defvar-local enable-catalog--filter nil
  "Active filter string, or nil for no filtering.")

(defun enable-catalog--script-status (fname event mod)
  "Return status string for script FNAME with feature EVENT in MOD."
  (cond
   ((featurep event) "enabled")
   ((assoc fname (enable-module-load-errors mod)) "error")
   ((member fname enable--skipped) "skipped")
   ((when-let* ((excl (gethash fname enable--exclusives)))
      (seq-some (lambda (e) (featurep (enable-event :file
                                                    (substring (symbol-name (enable-module-name mod)) 1)
                                                    e)))
                excl))
    "exclusive")
   (t "disabled")))

(defun enable-catalog--script-note (fname mod-str mod)
  "Return notes string for script FNAME in module MOD-STR."
  (cond
   ((when-let* ((entry (assoc fname (enable-module-load-errors mod))))
      (format "%S" (cdr entry))))
   ((when-let* ((excl (gethash fname enable--exclusives))
                (loaded (seq-find (lambda (e) (featurep (enable-event :file mod-str e))) excl)))
      (format "blocked by: %s" loaded)))
   (t "")))

(defun enable-catalog--match-p (filter cols)
  "Return non-nil if FILTER matches any string in COLS vector."
  (cl-some (lambda (s) (string-match-p (regexp-quote filter) s))
           (cl-coerce cols 'list)))

(defun enable-catalog--entries ()
  "Build tabulated list entries from all registered modules."
  (let (entries)
    (maphash
     (lambda (mod-name mod)
       (let ((mod-str (substring (symbol-name mod-name) 1)))
         (maphash
          (lambda (group scripts)
            (let ((group-str (substring (symbol-name group) 1)))
              (dolist (script scripts)
                (let* ((fname (symbol-name script))
                       (event (enable-event :file mod-str fname))
                       (status (enable-catalog--script-status fname event mod))
                       (note (enable-catalog--script-note fname mod-str mod))
                       (cols (vector mod-str group-str fname status note)))
                  (when (or (null enable-catalog--filter)
                            (enable-catalog--match-p enable-catalog--filter cols))
                    (push (list (cons mod-name script) cols) entries))))))
          (enable-module-groups mod))))
     enable--modules)
    entries))

(defun enable-catalog ()
  "Open the Enable Catalog."
  (interactive)
  (let ((buf (get-buffer-create "*Enable Catalog*")))
    (with-current-buffer buf
      (enable-catalog-mode)
      (setq tabulated-list-entries (enable-catalog--entries))
      (tabulated-list-print t))
    (pop-to-buffer buf)))

(defun enable-catalog-refresh ()
  "Refresh the catalog entries."
  (interactive)
  (setq tabulated-list-entries (enable-catalog--entries))
  (tabulated-list-print t))

(defun enable-catalog-filter (filter)
  "Filter catalog entries matching FILTER string across all columns."
  (interactive "sFilter: ")
  (setq enable-catalog--filter (if (string-empty-p filter) nil filter))
  (enable-catalog-refresh))

(defun enable-catalog-clear-filter ()
  "Clear active filter and refresh."
  (interactive)
  (setq enable-catalog--filter nil)
  (enable-catalog-refresh))

(defun enable-catalog-visit ()
  "Open the script at point."
  (interactive)
  (when-let* ((id (tabulated-list-get-id))
              (mod (gethash (car id) enable--modules))
              (cols (tabulated-list-get-entry))
              (group (intern (concat ":" (aref cols 1)))))
    (find-file (enable--script-path (enable-module-path mod) (cdr id) group))))

(defun enable-catalog-disable ()
  "Stage the script at point for disabling."
  (interactive)
  (tabulated-list-set-col 3 "disabled*")
  (forward-line 1))

(defun enable-catalog-enable ()
  "Stage the script at point for enabling."
  (interactive)
  (tabulated-list-set-col 3 "enabled*")
  (forward-line 1))

(defun enable-catalog-save ()
  "Write staged enable/disable changes to `enable-config-file'."
  (interactive)
  (unless (yes-or-no-p (format "Save changes to %s? " enable-config-file))
    (user-error "Aborted"))
  (let ((disabled (make-hash-table :test #'equal)))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when-let* ((id (tabulated-list-get-id))
                    (cols (tabulated-list-get-entry))
                    (status (aref cols 3)))
          (when (string-prefix-p "disabled" status)
            (let ((key (cons (car id) (intern (concat ":" (aref cols 1))))))
              (push (cdr id) (gethash key disabled)))))
        (forward-line 1)))
    (enable--write-config
     (enable--rebuild-section (enable--read-config :early) disabled)
     (enable--rebuild-section (enable--read-config :init) disabled))
    (message "enable: config saved to %s" enable-config-file)))

(defun enable--rebuild-section (decl disabled)
  "Rebuild config section DECL, excepting scripts in DISABLED."
  (cl-loop for (mod-name . body) in decl
           collect (cons mod-name
                         (cl-loop for group-spec in body
                                  collect (if (and (listp group-spec)
                                                   (keywordp (car group-spec)))
                                              (let ((dis (gethash (cons mod-name (car group-spec))
                                                                  disabled)))
                                                (if dis
                                                    `(,(car group-spec) :except ,dis)
                                                  group-spec))
                                            group-spec)))))

(defun enable--format-spec (spec base-indent extra-close)
  "Format group spec SPEC at BASE-INDENT with EXTRA-CLOSE additional closing parens."
  (let ((pad (make-string base-indent ?\s))
        (more (make-string extra-close ?\))))
    (pcase spec
      (`(,group :except ,excluded)
       (let ((inner-pad (make-string (1+ base-indent) ?\s))
             (elem-pad (make-string (+ 2 base-indent) ?\s)))
         (concat pad (format "(%s :except\n" group)
                 inner-pad "(" (symbol-name (car excluded))
                 (if (cdr excluded)
                     (concat "\n"
                             (mapconcat (lambda (e) (concat elem-pad (symbol-name e)))
                                        (cdr excluded) "\n")
                             "))" more)
                   (concat "))" more)))))
      (`(,group . ,args)
       (concat pad "(" (symbol-name group)
               (if args (concat " " (mapconcat #'symbol-name args " ")) "")
               ")" more)))))

(defun enable--write-section (tag module-decls)
  "Write section TAG with MODULE-DECLS to current buffer."
  (insert (format "(%s\n" tag))
  (let ((mod-rest module-decls))
    (while mod-rest
      (let* ((decl (car mod-rest))
             (last-mod (null (cdr mod-rest)))
             (specs (cdr decl)))
        (insert (format " (%s\n" (car decl)))
        (let ((spec-rest specs))
          (while spec-rest
            (let* ((spec (car spec-rest))
                   (last-spec (null (cdr spec-rest)))
                   (extra (if last-spec (if last-mod 2 1) 0)))
              (insert (enable--format-spec spec 2 extra))
              (insert "\n"))
            (setq spec-rest (cdr spec-rest)))))
      (setq mod-rest (cdr mod-rest)))))

(defun enable--write-config (early-section init-section)
  "Write EARLY-SECTION and INIT-SECTION to `enable-config-file'."
  (with-temp-file enable-config-file
    (insert ";;; enable config -*- lexical-binding: t; -*-\n")
    (insert ";; Managed by `enable-catalog-save'.  Manual edits are fine.\n\n")
    (enable--write-section :early early-section)
    (insert "\n")
    (enable--write-section :init init-section)))

(provide 'enable-catalog)
;;; enable-catalog.el ends here
