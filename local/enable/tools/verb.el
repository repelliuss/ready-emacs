;;; verb.el -*- lexical-binding: t; -*-

(cfg-pkg verb
  (:after-this
    (:bind verb-mode-map (:locally "v" verb-command-map))))
