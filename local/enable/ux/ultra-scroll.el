;;; ultra-scroll.el -*- lexical-binding: t; -*-

(cfg-pkg (:elpaca ultra-scroll
                    :host github
                    :repo "jdtsmith/ultra-scroll"
		            :files ("*.el"))
  (:opt scroll-conservatively 101
        scroll-margin 3)
  (ultra-scroll-mode 1))
