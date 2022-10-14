;;; forge.el -*- lexical-binding: t; -*-

(use-package forge
  :after magit
  :init
  (setq forge-database-file (concat cache-dir "forge-database.sqlite")))
