;;; cmake.el -*- lexical-binding: t; -*-

(use-package cmake-mode)

(use-package cmake-font-lock)

(use-package eldoc-cmake
  :hook (cmake-mode . eldoc-cmake-enable))
