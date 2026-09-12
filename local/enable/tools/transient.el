;;; transient.el -*- lexical-binding: t; -*-

(cfg-pkg transient
  (:opt transient-levels-file (concat rps-dir-cache "transient/levels.el")
        transient-values-file (concat rps-dir-cache "transient/values.el")
        transient-history-file (concat rps-dir-cache "transient/history.el")))

