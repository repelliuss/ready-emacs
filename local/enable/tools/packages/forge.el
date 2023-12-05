;;; forge.el -*- lexical-binding: t; -*-

(use-package forge
  :after magit
  :init
  (setq forge-database-file (concat $dir-cache "forge-database.sqlite")))
