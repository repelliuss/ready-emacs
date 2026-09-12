;;; hlsl-ts-mode.el -*- lexical-binding: t; -*-

(enable-when rps-user-work-p)

(cfg-pkg (:require (:elpaca hlsl-ts-mode
                              :host github
                              :repo "repelliuss/hlsl-ts-mode"
                              :protocol ssh)))

(cfg-pkg (:require (:elpaca lsp-shader-sense
                              :host github
                              :repo "repelliuss/lsp-shader-sense"
                              :protocol ssh)))

(cfg emacs
  (:after lsp-mode
    (:hook-to 'hlsl-ts-mode #'lsp-deferred)))

