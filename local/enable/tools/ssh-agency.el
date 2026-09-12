;;; ssh-agency.el -*- lexical-binding: t; -*-

(cfg-pkg ssh-agency
  (:after magit (:require ssh-agency))
  (:hook-to 'vc-retrieve-tag
    #'ssh-agency-ensure))
