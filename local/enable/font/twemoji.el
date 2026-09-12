;;; twemoji.el -*- lexical-binding: t; -*-

;; Windows already has its own color emoji font (Segoe UI Emoji); twemoji
;; is only meaningfully needed elsewhere.
;; Windows has Segoe UI Emoji; Android emoji is system-provided and
;; twemoji is not in Termux pkg.
(enable-when (not (or rps-system-windows-p rps-system-android-p)))

(store-install "twemoji")
