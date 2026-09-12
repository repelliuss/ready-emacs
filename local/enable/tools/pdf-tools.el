;;; pdf-tools.el -*- lexical-binding: t; -*-

(enable-when (not rps-system-android-p))

(store-install "poppler-devel"
  :pacman '(:name "mingw-w64-x86_64-poppler" :system windows)
  :pkg '(:name "poppler"))
;; The glib bindings are a separate xbps package; pacman/pkg bundle them
;; with poppler itself — a second install of the same pkg package is a no-op.
(store-install "poppler-glib-devel"
  :pacman '(:name "mingw-w64-x86_64-poppler" :system windows)
  :pkg '(:name "poppler"))

(cfg-pkg pdf-tools
  (:opt pdf-view-display-size 'fit-page)
  (pdf-loader-install))
