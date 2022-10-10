;;; org-gamedb.el -*- lexical-binding: t; -*-

(use-package org-gamedb
  :init
  (autoload #'rps-org-gamedb-game-capture "org-gamedb")
  
  :config
  (defun rps-org-gamedb-game-capture (entry)
    (org-insert-heading)
    (insert (concat " " entry))
    (call-interactively #'org-gamedb-games-query))

  :attach (org-capture)
  (dolist (elt '(("l" "Log")
		 ("lg" "Game" (rps-org-capture-log #'rps-org-gamedb-game-capture "game.org" "Game: "))))
    (add-to-list 'rps-org-capture-templates elt)))
