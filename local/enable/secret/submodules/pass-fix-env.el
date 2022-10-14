;;; pass-fix-env.el -*- lexical-binding: t; -*-

;; REVIEW: env here
(setenv "PASSWORD_STORE_DIR" (expand-file-name "~/.safe/pass"))
