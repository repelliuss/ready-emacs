;;; enable config -*- lexical-binding: t; -*-
;; Managed by `enable-catalog-save'.  Manual edits are fine.

(:early (:local (:core)))

(:init
 (:local
  (:secret)
  (:theme modus-themes)
  (:font fontaine aporetic ioskeley nerd-icons font-list)
  (:program)
  (:modeline doom-modeline)
  (:ui)
  (:ux)
  (:editor :except
           (project))
  (:tools :except
          (flyover
           eglot
           flymake))
  (:lang)))

