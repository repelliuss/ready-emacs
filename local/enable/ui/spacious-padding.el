;;; spacious-padding.el -*- lexical-binding: t; -*-

(cfg-pkg spacious-padding
  (:opt spacious-padding-subtle-frame-lines nil
        spacious-padding-widths (list :internal-border-width 32
                                      :fringe-width 8
                                      :header-line-width 0
                                      :mode-line-width 0
                                      :tab-width 4
                                      :right-divider-width 8
                                      :scroll-bar-width 8
                                      :fringe-width 8
                                      :custom-button-width 8))
  (spacious-padding-mode 1))
