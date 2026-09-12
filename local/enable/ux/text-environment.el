;;; text-environment.el -*- lexical-binding: t; -*-

;; prefer-coding-system sets the default but still allows auto-detection
;; of actual file line endings, unlike coding-system-for-read/write which
;; forces a specific encoding and prevents detection.
(prefer-coding-system 'utf-8)
