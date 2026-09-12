;;; dape.el -*- lexical-binding: t; -*-

(cfg-pkg (:require dape)
  (:opt dape-inlay-hints t
        dape-adapter-dir (:join-d rps-dir-cache "debugger")
        dape-info-hide-mode-line t
        dape-buffer-window-arrangement 'right
        dape-default-breakpoints-file (:join rps-dir-cache "dape" "breakpoints"))
  (:mkdir rps-dir-cache "dape")
  (:touch dape-default-breakpoints-file)
  (:prepend* display-buffer-alist '(("\\*dape-info.*\\*" . (nil . ((window-width . 0.4))))))

  (:after-this
    (:bind rps-keymap-leader "d" dape-global-map)
    (:hook-to 'kill-emacs-hook #'dape-breakpoint-save)
    (:hook-to 'dape-display-source-hook #'pulse-momentary-highlight-one-line)

    ;; stalls Emacs on windows
    (:advice-to #'dape--emacs-grab-focus :override #'ignore)))

