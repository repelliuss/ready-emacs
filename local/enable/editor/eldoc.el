;;; eldoc.el -*- lexical-binding: t; -*-

(cfg eldoc
  (:opt eldoc-echo-area-display-truncation-message nil
        eldoc-documentation-strategy #'eldoc-documentation-compose))
