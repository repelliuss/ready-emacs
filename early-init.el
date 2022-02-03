;;; early-init.el --- -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum
      package-enable-at-startup nil
      load-prefer-newer noninteractive)

(setq enable-modules-dir (setq enable-dir (concat user-emacs-directory "enable/"))
      enable-cache-dir (concat user-emacs-directory "cache/enable/"))

(load (concat user-emacs-directory "enable") nil 'nomessage)

(enable-init '((editor . (meow
                          ace-window
                          embark
                          consult
                          vertico
			  corfu
			  kind-icon
			  cape
			  wgrep))

               (tools . (magit))

               (lang . (org))

               (ui . (hl-todo
		      diff-hl))

               (ux . (which-key
                      orderless
                      marginalia
                      gcmh
		      helpful
		      pcmpl-args))))


(enable-early
 :init all
 :ui
 :sub (no-bar font frame)
 :pkg (modus-themes nano-modeline))

;; TODO: meow SPC G
