;;; config.el -*- lexical-binding: t; -*-

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq
 ;; Emacs spends too much effort recentering the screen if you scroll the
 ;; cursor more than N lines past window edges (where N is the settings of
 ;; `scroll-conservatively'). This is especially slow in larger files
 ;; during large-scale scrolling commands. If kept over 100, the window is
 ;; never automatically recentered.
 scroll-conservatively 101
 scroll-margin 0
 scroll-preserve-screen-position t
 ;; Reduce cursor lag by a tiny bit by not auto-adjusting `window-vscroll'
 ;; for tall lines.
 auto-window-vscroll nil
 ;; mouse
 mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
 mouse-wheel-scroll-amount-horizontal 2)

(advice-add #'scroll-up-command :after #'recenter)
(advice-add #'scroll-down-command :after #'recenter)
(advice-add #'scroll-up-command :filter-args (lambda (_)))
(advice-add #'scroll-down-command :filter-args (lambda (_)))

(rps/load-submodules 'ui mood-line)
