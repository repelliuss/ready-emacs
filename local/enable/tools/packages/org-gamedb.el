;;; org-gamedb.el -*- lexical-binding: t; -*-

(use-package org-gamedb
  :init
  (autoload #'/org-gamedb-capture-game "org-gamedb")
  
  :config
  (defun /org-gamedb-capture-game (entry)
    (org-insert-heading)
    (insert (concat " " entry))
    (call-interactively #'org-gamedb-games-query))

  :attach (org-capture)
  (dolist (elt '(("l" "Log")
		 ("lg" "Game" (rps-org-capture-log #'/org-gamedb-capture-game "game.org" "Game: "))))
    (add-to-list '/org-gtd-capture-templates elt)))
