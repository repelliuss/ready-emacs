;;; agent-shell.el -*- lexical-binding: t; -*-

(cfg-pkg agent-shell
  (:bind rps-keymap-leader
         (:autoload "a" #'agent-shell
                    "A" #'agent-shell-new-shell))

  (:opt agent-shell-dot-subdir-function #'rps-agent-shell-dot-subdir-function
        agent-shell-status-kind-label-function #'agent-shell--inverse-icon-status-kind-label
        agent-shell-prefer-viewport-interaction nil)

  (when rps-user-work-p
    (:prepend exec-path (file-name-concat (getenv "LOCALAPPDATA") "opencode"))
    (:opt agent-shell-preferred-agent-config '(preselect . opencode)))

  (when rps-user-home-desktop-p
    (:opt agent-shell-preferred-agent-config '(preselect . claude-code)))

  (when rps-system-windows-p
    (:opt agent-shell-path-resolver-function #'rps-agent-shell-resolve-path-for-windows))

  (:after-this
    (:bind rps-keymap-leader "a" #'agent-shell))

  ;; npm ships with nodejs itself, so no separate binary/setup step is
  ;; needed the way pnpm required.
  (store-thread
    (store-install "nodejs")
    :then
    (store-register store-current-system 'npm
      :query (lambda (name) (= 0 (call-process "npm" nil nil nil "view" name "version")))
      :check (lambda (name) (= 0 (call-process "npm" nil nil nil "list" "-g" name)))
      :install (lambda (name ctx)
                 (store-async-install-process ctx (format "npm:%s" name)
                   (list "sudo" "npm" "install" "-g" name)
                   :on-success (lambda () (store-install-ok ctx))))
      :update (lambda (name ctx)
                (store-async-install-process ctx (format "npm:update:%s" name)
                  (list "sudo" "npm" "update" "-g" name)
                  :on-success (lambda () (store-update-ok ctx))))
      :uninstall (lambda (name ctx)
                   (store-async-process (format "npm:remove:%s" name)
                       (list "sudo" "npm" "uninstall" "-g" name)
                     :on-success (lambda () (store-uninstall-ok ctx))
                     :on-fail (lambda () (store-uninstall-fail ctx)))))
    
    :then
    (store-install "claude-code"
      :npm '(:name "@anthropic-ai/claude-code"))

    :then
    (store-install "claude-agent-acp"
      :npm '(:name "@agentclientprotocol/claude-agent-acp"))

    :then
    ;; opencode-ai's package.json restricts `os' to
    ;; darwin/linux/win32 and Termux node reports `android' —
    ;; npm refuses the install outright there.
    (store-install "opencode"
      :npm '(:name "opencode-ai")
      :skip '(:system android))))

(cfg-pkg (:elpaca latex-to-svg-backend
                    :host github
                    :repo "alberti42/latex-to-svg-backend"))

(cfg-pkg (:elpaca agent-shell-math-renderer
                    :host github
                    :repo "alberti42/agent-shell-math-renderer")
  (:opt agent-shell-math-renderer-render-submitted-prompts t)
  (:hook-into agent-shell-mode)
  (:hook-to 'enable-theme-functions #'agent-shell-math-renderer-on-theme-change))

(cfg-pkg emcp
  (:opt emcp-default-profile 'inspect)
  (:after agent-shell
    (:prepend agent-shell-mcp-servers '((name . "emcp")
                                        (type . "http")
                                        (headers . ())
                                        (url . (lambda ()
                                                 (require 'emcp)
                                                 (let ((server (emcp-start emcp-default-profile)))
                                                   (emcp-server-url server))))))))

(defun rps-agent-shell-dot-subdir-function (subdir)
  (expand-file-name (file-name-concat ".agent-shell"
                                      (or (file-remote-p default-directory 'host) (system-name))
                                      (file-name-nondirectory (directory-file-name (agent-shell-cwd)))
                                      subdir)
                    rps-dir-cache))

(defun rps-agent-shell-resolve-path-for-windows (path)
  (let ((p (string-replace "/" "\\" path)))
    (when (string-match "^[a-z]" p)
      (setq p (replace-match (upcase (match-string 0 p)) t t p)))
    p))
