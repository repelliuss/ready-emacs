;;; optimize.el -*- lexical-binding: t; -*-

(setup-none
  (:set
   ;; A second, case-insensitive pass over `auto-mode-alist' is time wasted, and
   ;; indicates misconfiguration (don't rely on case insensitivity for file names).
   auto-mode-case-fold nil

   ;; Disable bidirectional text rendering for a modest performance boost. I've set
   ;; this to `nil' in the past, but the `bidi-display-reordering's docs say that
   ;; is an undefined state and suggest this to be just as good:
   bidi-display-reordering 'left-to-right
   bidi-paragraph-direction 'left-to-right

   ;; Reduce rendering/line scan work for Emacs by not rendering cursors or regions
   ;; in non-focused windows.
   cursor-in-non-selected-windows nil
   highlight-nonselected-windows nil

   ;; More performant rapid scrolling over unfontified regions. May cause brief
   ;; spells of inaccurate syntax highlighting right after scrolling, which should
   ;; quickly self-correct.
   fast-but-imprecise-scrolling t

   ;; Resizing the Emacs frame can be a terribly expensive part of changing the
   ;; font. By inhibiting this, we halve startup times, particularly when we use
   ;; fonts that are larger than the system default (which would resize the frame).
   frame-inhibit-implied-resize t


   ;; Emacs "updates" its ui more often than it needs to, so slow it down slightly
   idle-update-delay 1.0

   ;; Font compacting can be terribly expensive, especially for rendering icon
   ;; fonts on Windows. Whether disabling it has a notable affect on Linux and Mac
   ;; hasn't been determined, but do it there anyway, just in case. This increases
   ;; memory usage, however!
   inhibit-compacting-font-caches t

   ;; Increase how much is read from processes in a single chunk (default is 4kb).
   ;; This is further increased elsewhere, where needed (like our LSP module).
   read-process-output-max (* 1024 1024)

   ;; Introduced in Emacs HEAD (b2f8c9f), this inhibits fontification while
   ;; receiving input, which should help a little with scrolling performance.
   redisplay-skip-fontification-on-input t

   gc-cons-threshold 100000000))


