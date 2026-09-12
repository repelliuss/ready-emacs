;;; vc.el -*- lexical-binding: t; -*-

(cfg vc
  (:opt vc-find-revision-no-save t)
  (:bind rps-keymap-leader
         "v" vc-prefix-map))

(cfg-pkg (:require vc-defer)
  (:prepend vc-defer-backends 'Plastic)
  (vc-defer-mode 1))

(when rps-user-work-p
  (cfg-pkg (:require (:elpaca vc-plastic
                            :host github
                            :protocol ssh
                            :repo "repelliuss/vc-plastic"))))
