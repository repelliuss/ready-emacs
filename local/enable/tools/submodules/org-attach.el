;;; org-attach.el -*- lexical-binding: t; -*-

(use-package org-attach
  :straight (:type built-in)
  :config
  (setq org-attach-id-dir (concat org-directory ".attachments/")))
