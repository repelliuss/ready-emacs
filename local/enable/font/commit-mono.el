;;; commit-mono.el -*- lexical-binding: t; -*-

(store-install "https://github.com/eigilnikolajsen/commit-mono/releases/download/v1.143/CommitMono-1.143.zip"
  :url-font t
  :then
  (lambda ()
    (cfg fontaine
      (:after 'fontaine
        (:prepend* fontaine-presets '((regular-commit-mono :default-family "CommitMono"
                                                            :fixed-pitch-family "CommitMono"
                                                            :default-weight regular
                                                            :default-height 160)
                                       (regular-commit-mono-sm :default-family "CommitMono"
                                                                :fixed-pitch-family "CommitMono"
                                                                :default-weight regular
                                                                :default-height 100)))))))
