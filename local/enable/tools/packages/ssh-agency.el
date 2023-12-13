;;; ssh-agency.el -*- lexical-binding: t; -*-

(setup ssh-agency
  (:after-feature project
    (:with-function ssh-agency-ensure
      (:hook-into vc-retrieve-tag-hook))))
