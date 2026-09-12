;;; enable.el --- Declarative configuration manager -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'seq)

(defgroup enable nil
  "Declarative configuration manager for Emacs init scripts."
  :group 'convenience
  :prefix "enable-")

(defcustom enable-config-file (locate-user-emacs-file "enable/config.el")
  "File declaring which scripts to load and in which section."
  :type 'file)

(cl-defstruct enable-module
  "A registered configuration module."
  name path groups load-errors)

(defvar enable--modules (make-hash-table :test #'eq)
  "Module keyword -> `enable-module'.")

(defvar enable--context nil
  "Plist (:module :filename :path) for the script currently being loaded.")

(defvar enable--skipped nil
  "Script filenames skipped via `enable-when'.")

(defvar enable--exclusives (make-hash-table :test #'equal)
  "Filename -> list of mutually exclusive filenames.")

(defun enable--group-dir (base group)
  "Directory for GROUP keyword under BASE path.
The special group :root maps to BASE itself."
  (if (eq group :root)
      base
    (expand-file-name (substring (symbol-name group) 1) base)))

(defun enable--script-path (module-path script-name group)
  "Absolute path for SCRIPT-NAME in GROUP under MODULE-PATH."
  (expand-file-name (concat (symbol-name script-name) ".el")
                    (enable--group-dir module-path group)))

(defun enable--scan-group (mod group-name)
  "Return script name symbols on disk for GROUP-NAME in MOD, in natural sort order."
  (let ((dir (enable--group-dir (enable-module-path mod) group-name)))
    (when (file-directory-p dir)
      (mapcar (lambda (f) (intern (file-name-sans-extension f)))
              (sort (directory-files dir nil "\\.el\\'" t)
                    #'string-version-lessp)))))

(defun enable--group-files (mod group-name)
  "Scan disk for GROUP-NAME in MOD, cache and return results."
  (let ((files (enable--scan-group mod group-name)))
    (puthash group-name files (enable-module-groups mod))
    files))

(defun enable-module (name &rest args)
  "Register module NAME (keyword) with :path."
  (puthash name
           (make-enable-module :name name
                               :path (plist-get args :path)
                               :groups (make-hash-table :test #'eq))
           enable--modules))

(defun enable--read-config (section)
  "Read SECTION (:early or :init) from `enable-config-file'."
  (when (file-exists-p enable-config-file)
    (with-temp-buffer
      (insert-file-contents enable-config-file)
      (goto-char (point-min))
      (cl-loop with eof = (make-symbol "eof")
               for form = (condition-case nil (read (current-buffer))
                            (end-of-file eof))
               until (eq form eof)
               when (and (listp form) (eq (car form) section))
               return (cdr form)))))

(defun enable--resolve-group-files (mod group-name rest)
  "Resolve script names for GROUP-NAME in MOD given REST of the group spec."
  (pcase rest
    ('nil (enable--group-files mod group-name))
    (`(:except ,excluded)
     (seq-remove (lambda (f) (memq f excluded))
                  (enable--group-files mod group-name)))
    (scripts
     (puthash group-name scripts (enable-module-groups mod))
     scripts)))

(defun enable-event (type module name)
  "Feature symbol for event TYPE in MODULE/NAME.

TYPE is a keyword indicating when the event is provided:

  :file — Provided after a script finishes loading without error.
          Use this to check whether a script (feature) is enabled,
          since elpaca installs packages asynchronously and the
          package may not yet be available when the script loads.
          Example: (enable-event :file \"local\" \"ace-window\")"
  (intern (format "&%s:%s:%s"
                  (substring (symbol-name type) 1)
                  module name)))

(defun enable--load-file (group filename module)
  "Load FILENAME from GROUP in MODULE, recording errors."
  (let* ((path (enable--script-path (enable-module-path module) filename group))
         (mod-name (substring (symbol-name (enable-module-name module)) 1))
         (fname (symbol-name filename))
         (event (enable-event :file mod-name fname)))
    (cond
     ((featurep event))
     ((not (file-exists-p path))
      (push (cons fname path) (enable-module-load-errors module)))
     ((when-let* ((excl (gethash fname enable--exclusives)))
        (seq-some (lambda (e) (featurep (enable-event :file mod-name e))) excl)))
     (t
      (setq enable--context (list :module mod-name :filename fname :path path))
      (condition-case err
          (catch 'enable-skip
            (load path nil t)
            (provide event))
        (error
         (push (cons fname err) (enable-module-load-errors module))))))))

(defvar enable--bisect-filenames
  (when-let* ((f (getenv "ENABLE_BISECT_FILE")))
    (when (file-exists-p f)
      (with-temp-buffer
        (insert-file-contents f)
        (split-string (buffer-string) "\n" t))))
  "Script filenames to load during a bisect pass.")

(defun enable--load-group (mod group rest)
  "Load scripts directly in GROUP of MOD with REST spec."
  (cl-loop for f in (enable--resolve-group-files mod group rest)
           when (or (null enable--bisect-filenames)
                    (member (symbol-name f) enable--bisect-filenames))
           do (enable--load-file group f mod)))

(defun enable (section)
  "Load SECTION (:early or :init) from `enable-config-file'."
  (let ((enable--context nil))
    (dolist (module-decl (enable--read-config section))
      (let ((mod (or (gethash (car module-decl) enable--modules)
                     (error "enable: unknown module %s" (car module-decl)))))
        (dolist (group-spec (cdr module-decl))
          (enable--load-group mod (car group-spec) (cdr group-spec)))))))


(defmacro enable-when (condition &rest body)
  "Skip current script unless CONDITION holds, evaluating BODY before skip."
  `(unless ,condition
     (when-let* ((ctx enable--context))
       (cl-pushnew (plist-get ctx :filename) enable--skipped :test #'equal))
     ,@body
     (throw 'enable-skip nil)))

(defun enable-exclusive (&rest filenames)
  "Declare current script mutually exclusive with FILENAMES."
  (when-let* ((ctx enable--context)
              (current (plist-get ctx :filename)))
    (dolist (fname filenames)
      (cl-pushnew fname (gethash current enable--exclusives) :test #'equal)
      (cl-pushnew current (gethash fname enable--exclusives) :test #'equal))))

(defun enable-show-diagnostics ()
  "Display load diagnostics (errors, skipped, exclusive) from the last load pass."
  (interactive)
  (let ((buf (get-buffer-create "*Enable Diagnostics*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (when enable--skipped
          (insert "Skipped (enable-when condition failed):\n")
          (dolist (fname (reverse enable--skipped))
            (insert (format "  %s\n" fname)))
          (insert "\n"))
        (maphash (lambda (_name mod)
                   (cl-loop for (script . err) in (enable-module-load-errors mod)
                            do (insert (format "%s | %s | %S\n"
                                               (enable-module-name mod) script err))))
                 enable--modules)
        (when (= (point-min) (point-max))
          (insert "No diagnostics.\n")))
      (special-mode))
    (pop-to-buffer buf)))

(defun enable--collect-module-names ()
  "Return list of module name strings."
  (cl-loop for k being the hash-keys of enable--modules
           collect (substring (symbol-name k) 1)))

(defun enable--collect-scripts (mod)
  "Return list of script name strings registered in MOD."
  (cl-loop for scripts being the hash-values of (enable-module-groups mod)
           nconc (mapcar #'symbol-name scripts)))

(defun enable--find-script-group (mod script-sym)
  "Find the group containing SCRIPT-SYM in MOD."
  (cl-loop for grp being the hash-keys of (enable-module-groups mod)
           using (hash-values scripts)
           when (memq script-sym scripts) return grp))

(defun enable-find-script (module-name script-name group)
  "Visit SCRIPT-NAME in MODULE-NAME under GROUP.
Interactively, prompts for module, script, and optionally group."
  (interactive
   (let* ((mod-str (completing-read "Module: " (enable--collect-module-names) nil t))
          (mod-key (intern (concat ":" mod-str)))
          (mod (or (gethash mod-key enable--modules)
                   (user-error "Unknown module: %s" mod-str)))
          (existing (enable--collect-scripts mod))
          (script-str (completing-read
                       (format "Script in %s (select or type new): " mod-str)
                       existing nil nil))
          (script-sym (intern script-str)))
     (if (member script-str existing)
         (list mod-key script-sym (enable--find-script-group mod script-sym))
       (let* ((group-dirs (cl-loop for grp being the hash-keys of (enable-module-groups mod)
                                   collect (substring (symbol-name grp) 1)))
              (group-str (cl-loop for input = (completing-read
                                               (format "Group for '%s' in %s: "
                                                       script-str mod-str)
                                               group-dirs nil nil)
                                  until (not (string-empty-p input))
                                  do (message "Group name cannot be empty")
                                  finally return input)))
         (list mod-key script-sym (intern (concat ":" group-str)))))))
  (let* ((mod (or (gethash module-name enable--modules)
                  (user-error "Unknown module: %s" module-name)))
         (path (enable--script-path (enable-module-path mod) script-name group))
         (dir (file-name-directory path)))
    (unless (file-exists-p dir)
      (unless (yes-or-no-p (format "Create group directory '%s'? "
                                   (file-relative-name dir (enable-module-path mod))))
        (user-error "Aborted")))
    (make-directory dir t)
    (find-file path)))

(defvar enable--bisect-state nil
  "Plist (:candidates :good :bad) for the active bisect.")

(defun enable-bisect ()
  "Bisect which script causes a problem via spawned Emacs subprocesses."
  (interactive)
  (let ((all (cl-loop for f in features
                      for name = (symbol-name f)
                      when (string-prefix-p "&file:" name)
                      collect (car (last (split-string (substring name 6) ":"))))))
    (setq enable--bisect-state (list :candidates all :good nil :bad nil))
    (enable--bisect-step)))

(defun enable--bisect-step ()
  "Run one bisect step, narrowing candidates via a spawned Emacs."
  (let* ((candidates (plist-get enable--bisect-state :candidates))
         (n (length candidates)))
    (if (<= n 1)
        (progn
          (message "enable-bisect: %s"
                   (if candidates
                       (format "problematic script is %s" (car candidates))
                     "could not narrow down"))
          (setq enable--bisect-state nil))
      (let* ((half (/ n 2))
             (test-set (seq-take candidates half))
             (test-file (make-temp-file "enable-bisect-" nil ".txt")))
        (write-region (string-join test-set "\n") nil test-file nil 'silent)
        (message "enable-bisect: testing %d of %d scripts" half n)
        (let ((process-environment
               (cons (concat "ENABLE_BISECT_FILE=" test-file) process-environment)))
          (start-process "enable-bisect" nil
                         (expand-file-name invocation-name invocation-directory)))
        (plist-put enable--bisect-state :candidates
                   (if (yes-or-no-p "Is the problem still present?")
                       test-set
                     (seq-drop candidates half)))
        (enable--bisect-step)))))

(provide 'enable)
;;; enable.el ends here
