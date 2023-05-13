;;; bind-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "bind" "bind.el" (0 0 0 0))
;;; Generated autoloads from bind.el

(autoload 'bind-global-map "bind" "\
Return `current-global-map'." nil nil)

(autoload 'bind-local-map "bind" "\
Return local map while replicating the behavior of `local-set-key'." nil nil)

(autoload 'bind "bind" "\
Bind many keys to many keymaps, multiple times.
Syntax is `(bind FORM)' or `(bind (FORM)...)' so (FORM) is
repeatable.  See `bind--singular' for what a FORM is.
FORM-OR-FORMS can be a single FORM or list of FORMs.

\(fn &rest FORM-OR-FORMS)" nil t)

(autoload 'bind-undo "bind" "\
Undo (or unbind) `bind' FORM keys.

\(fn &rest FORM)" nil t)

(autoload 'bind-save "bind" "\
Return a save of current definitions of key sequences for debugging.
This function doesn't bind anything but return current
definitions so that returned save can be restored with
`bind-restore' after FORM is executed with `bind' in case the
result is unwanted.

This function still evaluates functions inside FORM like
`bind-repeat', so it is not side effect free.

\(fn &rest FORM)" nil t)

(autoload 'bind-restore "bind" "\
Restore definitions in SAVE from `bind-save'.

\(fn SAVE)" nil t)

(autoload 'bind-prefix "bind" "\
Prefix each KEY in BINDINGS with PREFIX of KEY is a string.
PREFIX can also be ending with a modifier, such as C-, S- C-S-
etc.

\(fn PREFIX &rest BINDINGS)" nil nil)

(function-put 'bind-prefix 'lisp-indent-function '1)

(autoload 'bind-autoload "bind" "\
If FILE-AS-SYMBOL-OR-KEY if symbol autoload DEF in BINDINGS or use metadata.
Note that `bind' doesn't provide :main-file prop so user must
provide it.  For example, one can utilize its package
configurator.

\(fn &optional FILE-AS-SYMBOL-OR-KEY &rest BINDINGS)" nil nil)

(function-put 'bind-autoload 'lisp-indent-function '1)

(autoload 'bind-repeat "bind" "\
Add repeating functionality to each DEF in BINDINGS for :main metadata.
This requires `repeat-mode' to be active to take effect.

\(fn &rest BINDINGS)" nil nil)

(function-put 'bind-repeat 'lisp-indent-function '0)

(register-definition-prefixes "bind" '("bind-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; bind-autoloads.el ends here
