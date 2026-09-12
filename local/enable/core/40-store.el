;;; 40-store.el --- System manager for package and font installation -*- lexical-binding: t; -*-

;; Standalone — no dependency on rps or core functions.
;; Will become its own package.
;;
;; Entry points:
;;   `store-register-system'  — register a system's metadata (predicate,
;;                               default store, font dir, unzip)
;;   `store-register'   — register (or replace) one store on an
;;                               already-registered system. The only way to
;;                               add a store — built-in or external callers
;;                               (e.g. agent-shell.el's npm store) use the
;;                               exact same function, the exact same way.
;;   `store-install'          — install a package name or an http(s) URL.
;;                               :post-install (ctx), if given, defers the
;;                               id being marked installed/provided until
;;                               POST-INSTALL itself eventually calls
;;                               `store-install-ok'/`store-install-fail'
;;                               on the ctx it receives (:post-install
;;                               already cleared from it) — for an
;;                               additional async step beyond the store's
;;                               own install that must also succeed (see
;;                               git.el's "git" install: the package alone
;;                               isn't enough, `git config' must also
;;                               succeed).
;;   `store-install-oneshot'  — gate an arbitrary one-off action behind
;;                               install state, independent of any store
;;   `store-thread'           — chain store calls flat via `:then'
;;                               markers, without nesting lambdas by hand
;;
;; Store entry plist keys (passed to `store-register'):
;;   :query      — (name) -> t, a version string, or nil. Tests whether
;;                 this store's *catalog/repo* has NAME available to
;;                 install — a real existence check (e.g. `xbps-query -R
;;                 name'), not a proxy like "is this a URL": a package
;;                 query must genuinely fail for a package the store
;;                 doesn't have, so dispatch correctly skips to the next
;;                 store. Entries with no :query are always available (as
;;                 if the query returned t). A version string return is
;;                 what lets a `:store' spec's :version requirement
;;                 (below) be checked.
;;   :install    — (name ctx). Must call `store-install-ok' or
;;                 `store-install-fail'.
;;   :uninstall  — (name ctx). Must call `store-uninstall-ok' or
;;                 `store-uninstall-fail'.
;;   :update     — (name ctx). Must call `store-update-ok' or
;;                 `store-update-fail'. Updates NAME to the latest version
;;                 available in this store. When the installed state carries
;;                 a :required-version (set at install time from a :version
;;                 spec), `store-update-pkg'/`store-update-font' skip the
;;                 update entirely rather than calling :update — a pinned
;;                 version is never bumped by an update call.
;;   :check      — (name) -> bool. A different question from :query: is
;;                 NAME *currently installed* via this store (e.g.
;;                 `xbps-query -S name')? Used by `store-available-p' to
;;                 verify an already-installed id is still actually
;;                 there, resolved via the id's persisted :store metadata
;;                 — only consulted when the id has no :installed-files
;;                 tracked (those are checked by file existence instead).
;;   :explicit-only — non-nil means this store is never a :default-store
;;                 or generic-fallback candidate — only reachable when a
;;                 caller names it directly via its own keyword. For a
;;                 store whose :query can't tell WHAT a name represents,
;;                 only THAT it's syntactically acceptable (url-font's
;;                 query is just "is this a URL" — true regardless of
;;                 what kind of resource the URL is), being reachable via
;;                 implicit fallback would silently assume intent the
;;                 caller never stated. url-font is explicit-only on
;;                 every system for exactly this reason: a caller must
;;                 write `:url-font nil' to mean "treat this URL as a
;;                 font," never get it by accident because every other
;;                 store's query happened to reject the URL first.
;;   :synchronous  — non-nil means at most one install runs at a time for
;;                 this store. A second `store-install' call while one is
;;                 already in progress is queued in
;;                 `store--sync-queues' and started automatically once
;;                 the running install finishes (ok or fail). Use for
;;                 stores that cannot handle concurrent invocations (e.g.
;;                 Android's pkg, which corrupts its lock file if two
;;                 installs run simultaneously).
;;
;; `store-install' store steering: any keyword besides :post-install/:then
;; names a store — since store symbols are registered at runtime (not known
;; when `store-install' is defined), this is done via &rest + &allow-other-
;; keys rather than a fixed lambda list. The keyword with its leading colon
;; stripped is the store symbol; its value is that store's props plist:
;;   (store-install "nodejs" :scoop '(:system windows))
;;   (store-install "claude-agent-acp" :npm '(:name "@agentclientprotocol/claude-agent-acp"))
;; SPEC props ::= (&key system version name)
;;   :system  restricts this spec to apply only when it matches
;;            `store-current-system' — filtered out before dispatch, not
;;            merely skipped-via-fallback.
;;   :name    overrides the package name passed to THIS store's
;;            :query/:install (e.g. "ripgrep" vs "BurntSushi.ripgrep.MSVC").
;;            Defaults to the call's own NAME-OR-URL. The logical id
;;            (state file / `store-feature-for-id' / :id) is unaffected.
;;   :version optional niladic function returning a required version
;;            string; the store's :query result must `string=' it or the
;;            spec is treated as unavailable, same as a failed query.
;;            Absent = accept whatever's latest/available, no comparison.
;; Named stores applicable to the current system are tried first, in
;; written order; if none are given at all, :default-store is tried first
;; instead; any remaining per-system stores not already named are tried
;; after, as generic fallback.
;;
;; A plain package name is installed via ordinary per-system store dispatch
;; — no separate "font store" concept for plain names; a system's regular
;; package manager already owns whatever OS-level registration a font
;; package needs. An http(s) URL is a plain string like any other NAME to
;; `store-install', but a URL alone never implies "font": `url-font' is
;; :explicit-only (above), so a caller must always name it directly, e.g.
;; (store-install "https://..." :url-font nil) — never picked up by
;; accident just because it was the only store willing to claim a
;; URL-shaped name during fallback. A future URL-consuming store for some
;; other kind of resource can coexist the same way, equally explicit.
;;
;; State files store an EDN-ish plist with install metadata, generically
;; persisted from whatever a store's :install stamped onto its ctx before
;; calling `store-install-ok' (minus :then, a closure that never hits disk):
;;   (:id ID :installed-at TIMESTAMP :store STORE :pkg-name NAME ...)
;; Read with `store--read-state', checked with `store-available-p'.

(require 'url)
(require 'cl-lib)

;;; State

(defvar store--registry (make-hash-table :test #'eq)
  "System handler registry.
Keys are system-id symbols (e.g. \\='void-linux, \\='windows) — plain
symbols, not keywords, same convention as store symbols.
Values are configuration plists.")

(defvar store-current-system nil
  "Active system identifier.
Set via `store-detect-system' or assign directly:
  (setq store-current-system \\='void-linux)")

(defvar store-install-state-dir nil
  "Directory where installation state marker files are kept.
Each installed item creates a file named by its id here.
Must be set before using any install functions.")

(defvar store--sync-busy (make-hash-table :test #'eq)
  "Per-store busy flag for synchronous stores.
Keys are store symbols; values are non-nil when an install is in progress.")

(defvar store--sync-queues (make-hash-table :test #'eq)
  "Per-store install queues for synchronous stores.
Keys are store symbols; values are lists of (ENTRY RESOLVED-NAME CTX) triples
waiting to be dispatched once the current install finishes.")

;;; System detection

(defun store-detect-system ()
  "Set `store-current-system' by testing each registered system's :predicate.
The first system whose predicate returns non-nil wins."
  (interactive)
  (setq store-current-system
        (cl-loop for id being the hash-keys of store--registry
                 using (hash-values config)
                 when (let ((pred (plist-get config :predicate)))
                        (and pred (funcall pred)))
                 return id)))

;;; Install state tracking (Emacs file ops — no shell)

(defun store--state-path (id)
  (expand-file-name id store-install-state-dir))

(defun store--installed-p (id)
  (and store-install-state-dir
       (file-exists-p (store--state-path id))))

(defun store--mark-installed (id &optional ctx)
  "Write install state for ID to a metadata plist file.
Persists whatever CTX carries (minus :then and :post-install, both
closures, and :id, already the file key) — a store's :install is free to
stamp arbitrary fields onto ctx before calling `store-install-ok'; there
is no fixed allow-list."
  (when store-install-state-dir
    (make-directory store-install-state-dir t)
    (let ((metadata (list :id id
                          :installed-at (format-time-string "%Y-%m-%dT%H:%M:%S"))))
      (when ctx
        (let ((rest (copy-sequence ctx)))
          (cl-remf rest :then)
          (cl-remf rest :id)
          (cl-remf rest :post-install)
          (setq metadata (append metadata rest))))
      (with-temp-file (store--state-path id)
        (prin1 metadata (current-buffer))))))

(defun store--read-state (id)
  "Return install metadata plist for ID, or nil if not installed."
  (let ((path (store--state-path id)))
    (when (and store-install-state-dir (file-exists-p path))
      (with-temp-buffer
        (insert-file-contents path)
        (condition-case nil (read (current-buffer)) (error nil))))))

(defun store-feature-for-id (id)
  "Return the feature symbol provided when ID is installed."
  (intern (concat "&store-" id)))

(defun store--provide (id)
  (provide (store-feature-for-id id)))

;;; Context

(defun store--make-ctx (id then)
  "Return an install context plist for ID with THEN callback."
  (list :id id :then then))

(defun store-install-next (ctx)
  "Invoke CTX's :then if present."
  (funcall (or (plist-get ctx :then) #'ignore)))

(defun store-install-ok (ctx)
  "Mark install successful: persist state with metadata, log, provide feature, call :then.
If CTX carries :post-install, delegate to it instead (with :post-install
cleared from the ctx it receives) — POST-INSTALL must eventually call
`store-install-ok' or `store-install-fail' itself, exactly like a
store's :install function does. This is what lets an id stay unprovided
until an additional async step (beyond the store's own install) succeeds."
  (if-let* ((post-install (plist-get ctx :post-install)))
      (let ((c (copy-sequence ctx)))
        (cl-remf c :post-install)
        (funcall post-install c))
    (let ((id (plist-get ctx :id)))
      (store--mark-installed id ctx)
      (message "store: installed %s" id)
      (store--provide id)
      (store-install-next ctx)
      (store--sync-maybe-drain ctx))))

(defun store-install-fail (ctx)
  "Report installation failure for CTX."
  (warn "store: failed to install %s" (plist-get ctx :id))
  (store--sync-maybe-drain ctx))

(defun store-update-ok (ctx)
  "Mark update successful: persist state with metadata, log, provide feature, call :then."
  (let ((id (plist-get ctx :id)))
    (store--mark-installed id ctx)
    (message "store: updated %s" id)
    (store--provide id)
    (store-install-next ctx)))

(defun store-update-fail (ctx)
  "Report update failure for CTX."
  (warn "store: failed to update %s" (plist-get ctx :id)))

(cl-defun store-install-oneshot (id fn &key then)
  "Call FN once, gated by install state ID.
FN receives a context plist and must call `store-install-ok' or
`store-install-fail' to complete. If ID is already installed,
skips FN and calls THEN immediately."
  (if (store--installed-p id)
      (progn
        (store--provide id)
        (and then (funcall then)))
    (funcall fn (store--make-ctx id then))))

(cl-defun store-install-oneshot-process (id name command &key then)
  "Run COMMAND (via `store-async-install-process') once, gated by install
state ID. Convenience wrapper for the common `store-install-oneshot' case
where FN is just \"run this command, store-install-ok on success\"."
  (declare (indent 2))
  (store-install-oneshot id
    (lambda (ctx)
      (store-async-install-process ctx name command
        :on-success (lambda () (store-install-ok ctx))))
    :then then))

;;; Uninstall state

(defun store--mark-uninstalled (id)
  (when store-install-state-dir
    (let ((path (store--state-path id)))
      (when (file-exists-p path)
        (delete-file path)))))

(defun store--unprovide (id)
  (setq features (delq (store-feature-for-id id) features)))

(defun store--installed-ids (&optional prefix)
  "Return installed ids from `store-install-state-dir', optionally filtered by PREFIX."
  (when store-install-state-dir
    (let ((files (directory-files store-install-state-dir nil "^[^.]")))
      (if prefix (cl-remove-if-not (lambda (f) (string-prefix-p prefix f)) files) files))))

(defun store-uninstall-ok (ctx)
  "Remove install state and call :then."
  (let ((id (plist-get ctx :id)))
    (store--mark-uninstalled id)
    (store--unprovide id)
    (message "store: uninstalled %s" id)
    (store-install-next ctx)))

(defun store-uninstall-fail (ctx)
  "Report uninstall failure for CTX."
  (warn "store: failed to uninstall %s" (plist-get ctx :id)))

(defun store--uninstall-via-store (id)
  "Resolve ID's originally-installing store from its state metadata and
dispatch uninstall to that store's own :uninstall handler."
  (let* ((metadata (store--read-state id))
         (store-symbol (plist-get metadata :store))
         (pkg-name (or (plist-get metadata :pkg-name) id))
         (config (store--system-config))
         (entry (and store-symbol config (assq store-symbol (plist-get config :stores))))
         (uninstall-fn (and entry (store--entry-uninstall-fn entry)))
         (ctx (store--make-ctx id nil)))
    (cond
     ((not metadata) (warn "store: no install state for %s" id))
     ((not uninstall-fn) (warn "store: store %s has no :uninstall handler for %s" store-symbol id))
     (t (funcall uninstall-fn pkg-name ctx)))))

(defun store-uninstall-pkg (name)
  "Uninstall package NAME via whichever store originally installed it."
  (interactive
   (list (completing-read "Uninstall package: "
                          (cl-remove-if (lambda (id) (string-prefix-p "font-" id))
                                        (store--installed-ids))
                          nil t)))
  (store--uninstall-via-store name))

(defun store-uninstall-font (name)
  "Uninstall font NAME via whichever store originally installed it."
  (interactive
   (list (let* ((ids (store--installed-ids "font-"))
                (names (mapcar (lambda (id) (substring id 5)) ids)))
           (completing-read "Uninstall font: " names nil t))))
  (store--uninstall-via-store (concat "font-" name)))

;;; Update state

(defun store--update-via-store (id)
  "Resolve ID's originally-installing store from its state metadata and
dispatch update to that store's own :update handler.
If the state carries :required-version the update is skipped — a pinned
version is never bumped by an update call."
  (let* ((metadata (store--read-state id))
         (required-version (plist-get metadata :required-version)))
    (cond
     ((not metadata)
      (warn "store: no install state for %s" id))
     (required-version
      (message "store: %s is pinned at version %s, skipping update" id required-version))
     (t
      (let* ((store-symbol (plist-get metadata :store))
             (pkg-name (or (plist-get metadata :pkg-name) id))
             (config (store--system-config))
             (entry (and store-symbol config (assq store-symbol (plist-get config :stores))))
             (update-fn (and entry (store--entry-update-fn entry)))
             (ctx (store--make-ctx id nil)))
        (cond
         ((not update-fn)
          (warn "store: store %s has no :update handler for %s" store-symbol id))
         (t (funcall update-fn pkg-name ctx))))))))

(defun store-update-pkg (name)
  "Update package NAME via whichever store originally installed it."
  (interactive
   (list (completing-read "Update package: "
                          (cl-remove-if (lambda (id) (string-prefix-p "font-" id))
                                        (store--installed-ids))
                          nil t)))
  (store--update-via-store name))

(defun store-update-font (name)
  "Update font NAME via whichever store originally installed it."
  (interactive
   (list (let* ((ids (store--installed-ids "font-"))
                (names (mapcar (lambda (id) (substring id 5)) ids)))
           (completing-read "Update font: " names nil t))))
  (store--update-via-store (concat "font-" name)))

;;; Async process

(defun store--append-process-sentinel (proc fn)
  "Chain FN as an additional sentinel after PROC's existing one."
  (let ((old (process-sentinel proc)))
    (set-process-sentinel
     proc
     (if old
         (lambda (p e) (funcall old p e) (funcall fn p e))
       fn))))

(cl-defun store-async-process (name command &key sentinel on-success on-fail)
  "Run COMMAND list asynchronously in a comint buffer named NAME.
ON-SUCCESS called (no args) on exit-code 0; ON-FAIL otherwise."
  (declare (indent 2))
  (if (not (executable-find (car command)))
      (and on-fail (funcall on-fail))
    (let* ((buf (apply #'make-comint-in-buffer name (generate-new-buffer name)
                       (car command) nil (cdr command)))
           (proc (get-buffer-process buf)))
      (store--append-process-sentinel
       proc
       (lambda (process event)
         (and sentinel (funcall sentinel process event))
         (if (and (eq 'exit (process-status process))
                  (= 0 (process-exit-status process)))
             (and on-success (funcall on-success))
           (and on-fail (funcall on-fail)))))
      buf)))

(defun store-async-install-process (ctx name command &rest args)
  "Like `store-async-process' with automatic fail-reporting for CTX."
  (declare (indent 2))
  (apply #'store-async-process name command
         :on-fail (lambda () (store-install-fail ctx))
         args))

;;; URL utilities (Emacs built-ins only — no curl)

(defun store--url-p (str)
  "Return non-nil if STR is an http(s) URL."
  (and (stringp str) (string-match-p "\\`https?://" str)))

(defun store--url-filename (url)
  "Extract the filename component from URL."
  (file-name-nondirectory
   (url-filename (url-generic-parse-url url))))

(defun store--download-url (url dest on-success on-fail)
  "Download URL to DEST using Emacs `url-retrieve'.
Calls ON-SUCCESS or ON-FAIL (both niladic) upon completion.
Parent directory of DEST is created if needed."
  (make-directory (file-name-directory dest) t)
  (url-retrieve
   url
   (lambda (status dest on-success on-fail)
     (unwind-protect
         (if-let* ((err (plist-get status :error)))
             (progn
               (message "store: download failed for %s: %s" dest err)
               (and on-fail (funcall on-fail)))
           (let ((coding-system-for-write 'binary))
             (goto-char (point-min))
             (re-search-forward "\r?\n\r?\n" nil t)
             (write-region (point) (point-max) dest nil :silent))
           (and on-success (funcall on-success)))
       (kill-buffer (current-buffer))))
   (list dest on-success on-fail)
   t))

;;; Platform utilities

(defun store--path-as-windows (path)
  "Convert PATH to Windows-style backslash separators."
  (string-replace "/" "\\" path))

;;; Font utilities (Emacs file ops — no shell)

(defun store--copy-fonts-flat (src dest-dir)
  "Copy font files from SRC into DEST-DIR as a flat list (no subdirectories).
SRC may be a font file or a directory; directories are searched recursively.
Recognized extensions: ttf, otf, woff, woff2.
Returns a list of absolute paths of the copied destination files."
  (make-directory dest-dir t)
  (let* ((font-re "\\.\\(ttf\\|otf\\|woff2?\\)\\'")
         (files (if (file-directory-p src)
                    (directory-files-recursively src font-re)
                  (when (string-match-p font-re src) (list src))))
         copied)
    (dolist (f files)
      (let ((dest (expand-file-name (file-name-nondirectory f) dest-dir)))
        (copy-file f dest t)
        (push dest copied)))
    (nreverse copied)))

;;; System registration

(cl-defun store-register-system (system-id
                                   &key
                                   predicate
                                   default-store
                                   font-dir
                                   unzip
                                   register-font
                                   unregister-font)
  "Register system-level metadata for SYSTEM-ID. No stores here — see
`store-register', the only way to add a store to a system.

SYSTEM-ID          — plain symbol, e.g. \\='void-linux, \\='windows (not a
                     keyword — same convention as store symbols).
PREDICATE          — niladic function; when non-nil this system is active.
                     Called by `store-detect-system' to select the system.
DEFAULT-STORE      — symbol of the default store used when :store is absent.
FONT-DIR           — path to user font directory for URL-downloaded fonts.
UNZIP              — function (ctx archive dest-dir on-success); extracts
                     ARCHIVE into DEST-DIR, calls ON-SUCCESS when done.
                     Shared by any store on this system that needs it
                     (system-wide, not per-store — unzip is a system-level
                     utility, not a store concern).
REGISTER-FONT      — function (ctx on-success); called by the shared
                     `url-font' store (registered once across every
                     system, see `store-register') after files are
                     copied into FONT-DIR, with ctx's :installed-files
                     already set — do whatever THIS system needs to make
                     the OS pick the font up (e.g. `fc-cache', a registry
                     edit). Optional; a system with nothing to do (e.g.
                     Android — a flat copy into FONT-DIR is enough) can
                     just omit it, defaulting to a no-op.
UNREGISTER-FONT    — function (ctx on-success); the inverse, called by
                     `url-font''s :uninstall with the same ctx shape,
                     after its files are already deleted. Also optional.

Availability verification (:check) is per-store — see `store-register'."
  (puthash system-id
           (list :predicate predicate
                 :default-store default-store
                 :font-dir font-dir
                 :unzip unzip
                 :register-font register-font
                 :unregister-font unregister-font)
           store--registry)
  (when (and predicate (funcall predicate))
    (setq store-current-system system-id)))

(defun store-available-p (id)
  "Return non-nil if ID is installed and still available on the current system.
If state metadata contains :installed-files, checks that all listed files exist.
Otherwise calls the ORIGINALLY-INSTALLING store's :check with the recorded
package name. If no :check is registered on that store, trusts the state
file alone."
  (when (store--installed-p id)
    (let* ((metadata (store--read-state id))
           (installed-files (plist-get metadata :installed-files)))
      (if installed-files
          (cl-every #'file-exists-p installed-files)
        (let* ((config (store--system-config))
               (store-symbol (plist-get metadata :store))
               (entry (and store-symbol config (assq store-symbol (plist-get config :stores))))
               (check-fn (and entry (store--entry-check-fn entry)))
               (pkg-name (or (plist-get metadata :pkg-name) id)))
          (if check-fn
              (not (null (funcall check-fn pkg-name)))
            t))))))

(defun store--system-config (&optional system)
  "Return config plist for SYSTEM or `store-current-system'."
  (gethash (or system store-current-system) store--registry))

;;; Dispatch helpers

(defun store--entry-fn (entry)
  "Return the install function from store ENTRY.
ENTRY value is either a function or a plist (:query Q-FN :install I-FN ...)."
  (let ((val (cdr entry)))
    (if (functionp val) val (plist-get val :install))))

(defun store--entry-uninstall-fn (entry)
  "Return the :uninstall function from store ENTRY, or nil."
  (let ((val (cdr entry)))
    (unless (functionp val)
      (plist-get val :uninstall))))

(defun store--entry-check-fn (entry)
  "Return the :check function from store ENTRY, or nil."
  (let ((val (cdr entry)))
    (unless (functionp val)
      (plist-get val :check))))

(defun store--entry-update-fn (entry)
  "Return the :update function from store ENTRY, or nil."
  (let ((val (cdr entry)))
    (unless (functionp val)
      (plist-get val :update))))

(defun store--entry-synchronous-p (entry)
  "Return non-nil if store ENTRY serialises installs one at a time.
When t, a second install request for this store while one is already
running is queued and started only after the running one finishes."
  (let ((val (cdr entry)))
    (unless (functionp val)
      (plist-get val :synchronous))))

(defun store--entry-explicit-only-p (entry)
  "Return non-nil if store ENTRY must never be reached via generic
fallback — only when a caller names it explicitly. For stores whose
:query can't actually tell what the caller wants (e.g. url-font's query
is just \"is this a URL\" — true for any URL-shaped name regardless of
what kind of resource it is), being reachable via implicit fallback would
silently assume caller intent that was never stated."
  (let ((val (cdr entry)))
    (unless (functionp val)
      (plist-get val :explicit-only))))

(defun store--entry-query-result (entry name)
  "Return ENTRY's :query result for NAME — t, a version string, or nil.
Entries with no :query are always available (as if :query returned t)."
  (let ((val (cdr entry)))
    (if (functionp val)
        t
      (let ((query-fn (plist-get val :query)))
        (if query-fn (funcall query-fn name) t)))))

(defun store--sync-maybe-drain (ctx)
  "If CTX's store is synchronous, clear its busy flag and start the next
queued install (if any). Called at the end of every synchronous install,
whether it succeeded or failed, so the queue never stalls."
  (let* ((store-sym (plist-get ctx :store))
         (config (store--system-config))
         (stores (and config (plist-get config :stores)))
         (entry (and store-sym stores (assq store-sym stores))))
    (when (and entry (store--entry-synchronous-p entry))
      (remhash store-sym store--sync-busy)
      (when-let* ((queue (gethash store-sym store--sync-queues))
                  (item (car queue)))
        (puthash store-sym (cdr queue) store--sync-queues)
        (puthash store-sym t store--sync-busy)
        (funcall (store--entry-fn (nth 0 item)) (nth 1 item) (nth 2 item))))))

(defconst store--install-fixed-keys '(:post-install :then :skip)
  "Keys on `store-install' that never name a store.")

(defun store--specs-from-plist (args)
  "Extract per-store specs from ARGS, the raw &rest plist of `store-install'.
Every keyword not in `store--install-fixed-keys' names a store —
STORE-SYMBOL is that keyword with its leading colon stripped, paired with
its value as that store's props plist (:system :version :name).
Returns a list of (STORE-SYMBOL . PROPS) conses, in the order written."
  (let (specs)
    (while args
      (let ((key (car args)) (props (cadr args)))
        (unless (memq key store--install-fixed-keys)
          (push (cons (intern (substring (symbol-name key) 1)) props) specs))
        (setq args (cddr args))))
    (nreverse specs)))

(defun store--spec-symbol (spec)
  (car spec))

(defun store--spec-props (spec)
  (cdr spec))

(defun store--skip-specs-from-plist (args)
  "Extract :skip props plists from ARGS, one per :skip key."
  (let (skips)
    (while args
      (when (eq (car args) :skip)
        (push (cadr args) skips))
      (setq args (cddr args)))
    (nreverse skips)))

(defun store--skip-applies-to-current-system-p (props)
  "Return non-nil if skip PROPS applies to the current system.
A skip with no :system applies everywhere."
  (let ((sys (plist-get props :system)))
    (or (null sys) (eq sys store-current-system))))

(defun store--skip-entire-p (skips)
  "Return non-nil if any skip spec applies and carries no :store — skip the whole install."
  (cl-some (lambda (props)
              (and (store--skip-applies-to-current-system-p props)
                   (null (plist-get props :store))))
            skips))

(defun store--skipped-store-syms (skips)
  "Return list of store symbols to exclude on the current system."
  (let (syms)
    (dolist (props skips)
      (when-let* (((store--skip-applies-to-current-system-p props))
                  (store (plist-get props :store)))
        (push store syms)))
    syms))

(defun store--applies-to-current-system-p (spec)
  "A spec's :system, when given, must match `store-current-system';
specs with no :system always pass through."
  (let ((sys (plist-get (store--spec-props spec) :system)))
    (or (null sys) (eq sys store-current-system))))

(defun store--query-satisfies-version (queried version-fn)
  (or (null version-fn)
      (and (stringp queried) (string= queried (funcall version-fn)))))

(defun store--try-store-spec (spec stores default-name)
  "Return (ENTRY RESOLVED-NAME REQUIRED-VERSION) if SPEC's store is
registered, available for the resolved name, and satisfies its own
:version (if any). nil otherwise.
REQUIRED-VERSION is the string returned by the spec's :version function,
or nil when no version was required."
  (let* ((entry (assq (store--spec-symbol spec) stores))
         (props (let ((p (store--spec-props spec))) (if (eq p t) nil p)))
         (name (or (plist-get props :name) default-name))
         (version-fn (plist-get props :version)))
    (when entry
      (let ((queried (store--entry-query-result entry name)))
        (when (and queried (store--query-satisfies-version queried version-fn))
          (list entry name (and version-fn (funcall version-fn))))))))

(defun store--build-preferred-specs (config specs skip-syms)
  "Return the preferred (STORE-SYMBOL . PROPS) specs to try first.
SPECS filtered down to those applicable to the current system, minus
any store in SKIP-SYMS. When none remain, falls back to a single spec
for CONFIG's :default-store (unless it's :explicit-only or itself in
SKIP-SYMS)."
  (let* ((stores (plist-get config :stores))
         (preferred (cl-remove-if-not #'store--applies-to-current-system-p specs))
         (preferred (cl-remove-if (lambda (s) (memq (store--spec-symbol s) skip-syms)) preferred)))
    (or preferred
        (let ((d (plist-get config :default-store)))
          (and d
               (not (store--entry-explicit-only-p (assq d stores)))
               (not (memq d skip-syms))
               (list (cons d nil)))))))

(defun store--build-fallback-specs (config preferred skip-syms)
  "Return the generic-fallback specs for CONFIG: every registered store
not already in PREFERRED, not :explicit-only, and not in SKIP-SYMS."
  (let ((stores (plist-get config :stores))
        (preferred-syms (mapcar #'store--spec-symbol preferred)))
    (mapcar (lambda (e) (cons (car e) nil))
            (cl-remove-if
             (lambda (e) (or (memq (car e) preferred-syms)
                             (store--entry-explicit-only-p e)
                             (memq (car e) skip-syms)))
             stores))))

(defun store--dispatch-found (found ctx post-install)
  "Stamp FOUND's resolved store/name/version onto CTX, then either queue
it behind a busy synchronous store or dispatch it immediately."
  (let* ((entry (nth 0 found))
         (resolved-name (nth 1 found))
         (required-version (nth 2 found))
         (store-sym (car entry))
         (c (copy-sequence ctx)))
    (plist-put c :store store-sym)
    (plist-put c :pkg-name resolved-name)
    (when required-version (plist-put c :required-version required-version))
    (when post-install (plist-put c :post-install post-install))
    (if (and (store--entry-synchronous-p entry)
             (gethash store-sym store--sync-busy))
        (puthash store-sym
                 (append (gethash store-sym store--sync-queues)
                         (list (list entry resolved-name c)))
                 store--sync-queues)
      (when (store--entry-synchronous-p entry)
        (puthash store-sym t store--sync-busy))
      (funcall (store--entry-fn entry) resolved-name c))))

(defun store--dispatch-to-store (config name ctx &optional specs post-install skips)
  "Dispatch install of NAME through a store handler, with automatic fallback.

SPECS is a list of (STORE-SYMBOL . PROPS) conses — see
`store--specs-from-plist'. Specs applicable to the current system
are tried first, in order; if none are given at all, :default-store is
tried first instead (unless it's :explicit-only, in which case there is
no default); any remaining per-system stores not already named are tried
after, as generic fallback, except :explicit-only ones — those are only
ever reached by a caller naming them explicitly in SPECS, never as a
default or via fallback. POST-INSTALL, if given, is stamped onto ctx —
see `store-install-ok'.

SKIPS is a list of props plists from :skip specs — see
`store--skip-specs-from-plist'. A skip with no :store and a matching
:system (or no :system) short-circuits the entire install, calling :then
immediately. A skip with a :store excludes that store from both preferred
and fallback when its :system matches (or has no :system)."
  (if (store--skip-entire-p skips)
      (store-install-next ctx)
    (let* ((stores (plist-get config :stores))
           (skip-syms (store--skipped-store-syms skips))
           (preferred (store--build-preferred-specs config specs skip-syms))
           (fallback (store--build-fallback-specs config preferred skip-syms))
           (found (cl-some (lambda (spec) (store--try-store-spec spec stores name))
                           (append preferred fallback))))
      (if (not found)
          (store-install-fail ctx)
        (store--dispatch-found found ctx post-install)))))

(cl-defun store-register (system-ids store-symbol
                                  &key query install uninstall check update explicit-only synchronous then)
  "Add/replace store STORE-SYMBOL identically on each of SYSTEM-IDS
(already-registered systems this store's logic applies to unchanged —
SYSTEM-IDS may be a single system symbol or a list of them, e.g. url-font
registers the exact same QUERY/INSTALL/UNINSTALL across every system that
downloads fonts the same way; per-system variation, when there is any,
belongs in the system's own config — see :register-font/:unregister-font
on `store-register-system' — not in a second copy of the store).
The only way to add a store — used uniformly for every built-in store and
by external callers alike (e.g. agent-shell.el's npm store).

QUERY, INSTALL, UNINSTALL, CHECK, EXPLICIT-ONLY — see the store entry
plist keys documented in the header comment. QUERY and CHECK are
different operations even when they hit the same underlying tool: QUERY
asks \"does this store's *catalog/repo* have this package\" (used to pick
a store during dispatch — a package query must genuinely fail for a
package the store doesn't have, e.g. `xbps-query -R', not a proxy check
like \"is this a URL\"), CHECK asks \"is this package *currently
installed* via this store\" (e.g. `xbps-query -S') — used by
`store-available-p' to verify an already-installed id is still actually
there. EXPLICIT-ONLY non-nil means this store is never a default/fallback
candidate — only reachable when a caller names it directly (see
url-font: its :query — \"is this a URL\" — can't tell what KIND of
resource the URL is, so it must not silently claim any URL-shaped
install a caller never said was a font).

Registration is always synchronous, so THEN (if given) is called once,
after registering on all of SYSTEM-IDS — lets this slot into a
`store-thread' chain like any other store entry point."
  (declare (indent 2))
  (dolist (system-id (if (listp system-ids) system-ids (list system-ids)))
    (let ((config (store--system-config system-id)))
      (unless config
        (error "store-register: system %s is not registered" system-id))
      (let* ((entry (list store-symbol :query query :install install
                           :uninstall uninstall :check check :update update
                           :explicit-only explicit-only :synchronous synchronous))
             ;; Append (not prepend), so fallback dispatch order matches the
             ;; order stores were actually registered in, not its reverse.
             (new-stores (append (cl-remove store-symbol (plist-get config :stores) :key #'car)
                                  (list entry))))
        (puthash system-id (plist-put config :stores new-stores) store--registry))))
  (and then (funcall then)))

;;; Install operations

(defun store--specs-required-version (specs)
  "Return the required version string from the first applicable spec that
has a :version function, or nil when no version is pinned."
  (cl-some (lambda (spec)
              (when (store--applies-to-current-system-p spec)
                (when-let* ((ver-fn (plist-get (store--spec-props spec) :version)))
                  (funcall ver-fn))))
            specs))

(cl-defun store-install (name-or-url &rest args &key post-install then &allow-other-keys)
  "Install NAME-OR-URL — a plain package name or an http(s) URL.

Any keyword besides :post-install/:then names a store — the keyword with
its leading colon stripped is the store symbol, and its value is that
store's props plist:
  :system   — this spec only applies when it matches `store-current-system';
              on any other system it's as if the keyword were never given.
  :name     — overrides the package name passed to THIS store's
              :query/:install (e.g. \"ripgrep\" vs \"BurntSushi.ripgrep.MSVC\").
              The logical id (state file / `store-feature-for-id' / :id)
              is unaffected — always NAME-OR-URL.
  :version  — niladic function returning a required version string; the
              store's :query result must `string=' it or this spec is
              treated as unavailable, same as a failed query. Absent =
              accept whatever's latest/available, no comparison.
Named stores applicable to the current system are tried first, in written
order; if none are given at all, :default-store is tried first instead;
any remaining per-system stores not already named are tried after, as
generic fallback.

POST-INSTALL, if given, is a function (ctx) run after the chosen store
would otherwise have called `store-install-ok' — NAME-OR-URL's id is not
actually marked installed/provided until POST-INSTALL itself eventually
calls `store-install-ok' or `store-install-fail' on the ctx it receives
(:post-install already cleared from it). Lets an id stay ungated on an
additional async step beyond the store's own install (e.g. git.el's
\"git\" install: `git config' must also succeed before \"git\" is
considered installed, not just the package itself).

THEN is called on completion."
  (declare (indent 1))
  (let* ((config (store--system-config))
         (id (if (store--url-p name-or-url)
                 (concat "font-" (store--url-filename name-or-url))
               name-or-url))
         (ctx (store--make-ctx id then))
         (specs (store--specs-from-plist args))
         (skips (store--skip-specs-from-plist args)))
    (if (not config)
        (store-install-fail ctx)
      (if (store--installed-p id)
          (let* ((metadata (store--read-state id))
                 (installed-version (plist-get metadata :required-version))
                 (required-version (store--specs-required-version specs)))
            (if (and installed-version
                     (not (equal required-version installed-version)))
                ;; Version mismatch — reinstall rather than skip.
                (store--dispatch-to-store config name-or-url ctx specs post-install skips)
              (store--provide id)
              (and then (funcall then))))
        (store--dispatch-to-store config name-or-url ctx specs post-install skips)))))

;;; Threading macro

(defmacro store-thread (&rest forms)
  "Chain store install forms without nesting :then lambdas by hand.
FORMS is a flat sequence of calls interleaved with `:then' markers;
each marker's following forms become the :then callback of the
immediately preceding call, recursively."
  (declare (indent 0))
  (store--thread-expand forms))

(defun store--thread-expand (forms)
  (let ((pos (cl-position :then forms)))
    (if (not pos)
        (if (= (length forms) 1) (car forms) `(progn ,@forms))
      (let* ((head (cl-subseq forms 0 pos))
             (rest (nthcdr (1+ pos) forms))
             (call-form (car (last head)))
             (pre-forms (butlast head)))
        (when (memq :then call-form)
          (error "store-thread: form %S already has an explicit :then" call-form))
        `(progn
           ,@pre-forms
           ,(append call-form
                    (list :then `(lambda () ,(store--thread-expand rest)))))))))

;;; Shared url-font store — one definition, registered across every
;;; system (see the unified `store-register' call further below).
;;; Per-system variation (fc-cache, a registry edit, or nothing at all)
;;; lives entirely in each system's own :register-font/:unregister-font,
;;; not in a second copy of this store.

(defun store--url-font-install (url ctx)
  (let* ((config (store--system-config))
         (font-dir (plist-get config :font-dir))
         (register-font (or (plist-get config :register-font)
                             (lambda (_ctx on-success) (funcall on-success))))
         (filename (store--url-filename url))
         (dest (expand-file-name filename font-dir)))
    (plist-put ctx :url url)
    (cl-flet ((finish (files)
                (plist-put ctx :installed-files files)
                (funcall register-font ctx (lambda () (store-install-ok ctx)))))
      (store--download-url
       url dest
       (lambda ()
         (if (string-match-p "\\.zip\\'" dest)
             (let ((tmp (make-temp-file "store-font" t)))
               (funcall (plist-get config :unzip) ctx dest tmp
                        (lambda ()
                          (let ((copied (store--copy-fonts-flat tmp font-dir)))
                            (delete-file dest)
                            (delete-directory tmp t)
                            (finish copied)))))
           ;; Plain font file: already at its final destination (DEST is
           ;; directly inside FONT-DIR), nothing left to copy.
           (finish (list dest))))
       (lambda () (store-install-fail ctx))))))

(defun store--url-font-update (url ctx)
  (let* ((config (store--system-config))
         (id (plist-get ctx :id))
         (metadata (store--read-state id))
         (old-files (plist-get metadata :installed-files))
         (unregister-font (or (plist-get config :unregister-font)
                               (lambda (_ctx on-success) (funcall on-success)))))
    (dolist (f old-files) (when (file-exists-p f) (delete-file f)))
    (plist-put ctx :installed-files old-files)
    (funcall unregister-font ctx
             (lambda () (store--url-font-install url ctx)))))

(defun store--url-font-uninstall (_name ctx)
  (let* ((config (store--system-config))
         (id (plist-get ctx :id))
         (metadata (store--read-state id))
         (installed-files (plist-get metadata :installed-files))
         (unregister-font (or (plist-get config :unregister-font)
                               (lambda (_ctx on-success) (funcall on-success)))))
    (dolist (f installed-files) (when (file-exists-p f) (delete-file f)))
    (plist-put ctx :installed-files installed-files)
    (funcall unregister-font ctx (lambda () (store-uninstall-ok ctx)))))

;;; Built-in system font helpers
;;; Signature (ctx on-success): ctx's :installed-files is already set by
;;; the time these run — void-linux/windows read it from there; a system
;;; with nothing to do (Android) simply omits these entirely.

(defun store--void-linux-register-font (ctx on-success)
  (store-async-install-process ctx "store:fc-cache"
    (list "fc-cache" "-fv")
    :on-success on-success))

(defun store--void-linux-unregister-font (ctx on-success)
  (store-async-process "store:fc-cache"
    (list "fc-cache" "-fv")
    :on-success on-success
    :on-fail (lambda () (store-uninstall-fail ctx))))

(defconst store--windows-font-reg-key
  "HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts")

(defun store--windows-register-font (ctx on-success)
  (let ((ps-cmd (mapconcat
                 (lambda (f)
                   (format "Set-ItemProperty -Path '%s' -Name '%s (TrueType)' -Value '%s'"
                           store--windows-font-reg-key (file-name-base f) (file-name-nondirectory f)))
                 (plist-get ctx :installed-files) "; ")))
    (store-async-install-process ctx "store:windows:register-fonts"
      (list "powershell" "-Command" ps-cmd)
      :on-success on-success)))

(defun store--windows-unregister-font (ctx on-success)
  (let ((ps-cmd (mapconcat
                 (lambda (f)
                   (format "Remove-ItemProperty -Path '%s' -Name '%s (TrueType)' -ErrorAction SilentlyContinue"
                           store--windows-font-reg-key (file-name-base f)))
                 (plist-get ctx :installed-files) "; ")))
    (store-async-process "store:windows:unregister-fonts"
      (list "powershell" "-Command" ps-cmd)
      :on-success on-success
      :on-fail (lambda () (store-uninstall-fail ctx)))))

;;; Built-in system registrations

(store-register-system 'void-linux
  :predicate (lambda ()
               (and (eq system-type 'gnu/linux)
                    (or (file-exists-p "/usr/bin/xbps-install")
                        (executable-find "xbps-install"))))
  :default-store 'xbps
  :font-dir (expand-file-name "~/.local/share/fonts")
  :unzip (lambda (ctx archive dest-dir on-success)
           (store-async-install-process ctx "store:unzip"
             (list "unzip" "-o" archive "-d" dest-dir)
             :on-success on-success)))

(store-register 'void-linux 'xbps
  :query (lambda (name) (= 0 (call-process "xbps-query" nil nil nil "-R" name)))
  :check (lambda (name) (= 0 (call-process "xbps-query" nil nil nil "-S" name)))
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "xbps:%s" name)
               (list "sudo" "xbps-install" "-Sy" name)
               :on-success (lambda () (store-install-ok ctx))))
  :update (lambda (name ctx)
            (store-async-install-process ctx (format "xbps:update:%s" name)
              (list "sudo" "xbps-install" "-Su" name)
              :on-success (lambda () (store-update-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "xbps:remove:%s" name)
                 (list "sudo" "xbps-remove" "-y" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

(store-register-system 'windows
  :predicate (lambda () (memq system-type '(cygwin windows-nt ms-dos)))
  :default-store 'pacman
  :font-dir (expand-file-name "AppData/Local/Microsoft/Windows/Fonts" "~")
  :unzip (lambda (ctx archive dest-dir on-success)
           (store-async-install-process ctx "store:windows:unzip"
             (list "powershell" "-Command"
                   (format "Expand-Archive -Path '%s' -DestinationPath '%s' -Force"
                           (store--path-as-windows archive)
                           (store--path-as-windows dest-dir)))
             :on-success on-success)))

(store-register 'windows 'pacman
  ;; MSYS2's pacman. Assumes its bin dir is on PATH (e.g. C:\msys64\usr\bin
  ;; or C:\msys64\mingw64\bin) — no msys2_shell.cmd wrapper, unlike the
  ;; separate msys2-mingw64.el package.
  :query (lambda (name) (= 0 (call-process "pacman" nil nil nil "-Si" name)))
  :check (lambda (name) (= 0 (call-process "pacman" nil nil nil "-Q" name)))
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "pacman:%s" name)
               (list "pacman" "-S" "--noconfirm" "--needed" name)
               :on-success (lambda () (store-install-ok ctx))))
  :update (lambda (name ctx)
            (store-async-install-process ctx (format "pacman:update:%s" name)
              (list "pacman" "-Su" "--noconfirm" name)
              :on-success (lambda () (store-update-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "pacman:remove:%s" name)
                 (list "pacman" "-R" "--noconfirm" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

(store-register 'windows 'winget
  :query (lambda (name) (= 0 (call-process "winget" nil nil nil "show" "--id" name "--exact")))
  :check (lambda (name)
           ;; Try winget first; fall back to executable-find for CLI tools
           ;; winget doesn't manage but the name is still findable on PATH.
           (or (= 0 (call-process "winget" nil nil nil "list" "--id" name "--exact"))
               (not (null (executable-find name)))))
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "winget:%s" name)
               (list "winget" "install" "--id" name
                     "--accept-package-agreements"
                     "--accept-source-agreements")
               :on-success (lambda () (store-install-ok ctx))))
  :update (lambda (name ctx)
            (store-async-install-process ctx (format "winget:update:%s" name)
              (list "winget" "upgrade" "--id" name
                    "--accept-package-agreements"
                    "--accept-source-agreements")
              :on-success (lambda () (store-update-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "winget:remove:%s" name)
                 (list "winget" "uninstall" "--id" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

(store-register 'windows 'scoop
  :query (lambda (name) (= 0 (call-process "scoop" nil nil nil "info" name)))
  :check (lambda (name) (= 0 (call-process "scoop" nil nil nil "list" name)))
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "scoop:%s" name)
               (list "scoop" "install" name)
               :on-success (lambda () (store-install-ok ctx))))
  :update (lambda (name ctx)
            (store-async-install-process ctx (format "scoop:update:%s" name)
              (list "scoop" "update" name)
              :on-success (lambda () (store-update-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "scoop:remove:%s" name)
                 (list "scoop" "uninstall" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

;; Generic bucket management: some packages (e.g. stockfish) only live in
;; one of scoop's third-party buckets, not the default "main" one. NAME is
;; the bucket name — a caller opts in explicitly (see chess.el), adds the
;; bucket via this store, then installs the actual package via `scoop'
;; itself (now able to see it). explicit-only: adding a bucket is never a
;; fallback guess for an arbitrary install.
(store-register 'windows 'scoop-bucket
  :explicit-only t
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "scoop:bucket-add:%s" name)
               (list "scoop" "bucket" "add" name)
               :on-success (lambda () (store-install-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "scoop:bucket-remove:%s" name)
                 (list "scoop" "bucket" "rm" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

(store-register-system 'android
  :predicate (lambda () (eq system-type 'android))
  :default-store 'pkg
  ;; Fonts must be flat files directly in ~/fonts/ — subdirs are not scanned.
  ;; See (info "(emacs) Android Fonts").
  :font-dir (expand-file-name "~/fonts/")
  :unzip (lambda (ctx archive dest-dir on-success)
           (store-async-install-process ctx "store:unzip"
             (list "unzip" "-o" archive "-d" dest-dir)
             :on-success on-success)))

(store-register 'android 'pkg
  ;; pkg does not support concurrent installs — running two `pkg install'
  ;; processes simultaneously corrupts its lock state. :synchronous t
  ;; ensures installs are queued and run one at a time.
  :synchronous t
  :query (lambda (name) (= 0 (call-process "pkg" nil nil nil "show" name)))
  :check (lambda (name) (= 0 (call-process "pkg" nil nil nil "list-installed" name)))
  :install (lambda (name ctx)
             (store-async-install-process ctx (format "pkg:%s" name)
               (list "pkg" "install" "-y" name)
               :on-success (lambda () (store-install-ok ctx))))
  :update (lambda (name ctx)
            (store-async-install-process ctx (format "pkg:update:%s" name)
              (list "pkg" "upgrade" "-y" name)
              :on-success (lambda () (store-update-ok ctx))))
  :uninstall (lambda (name ctx)
               (store-async-process (format "pkg:remove:%s" name)
                 (list "pkg" "uninstall" "-y" name)
                 :on-success (lambda () (store-uninstall-ok ctx))
                 :on-fail (lambda () (store-uninstall-fail ctx)))))

;; One shared url-font store across every system — see the functions'
;; own comment above ("Shared url-font store").
(store-register '(void-linux windows android) 'url-font
  :query (lambda (name) (store--url-p name))
  :explicit-only t
  :install #'store--url-font-install
  :update #'store--url-font-update
  :uninstall #'store--url-font-uninstall)

(provide 'store)

;;; 40-store.el ends here
