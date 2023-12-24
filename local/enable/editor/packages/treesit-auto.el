;;; treesit-auto.el -*- lexical-binding: t; -*-

(setup (:require treesit-auto)
  (:set treesit-auto-install 'prompt
        (remove treesit-auto-langs) 'c-sharp)
  (global-treesit-auto-mode))

