;;; git.el -*- lexical-binding: t; -*-

(store-thread
  (store-install "git"
    :post-install
    (lambda (ctx)
      (if (= 0 (shell-command
                (string-join '("git config --global user.name repelliuss"
                               "git config --global user.email repelliuss@gmail.com"
                               "git config --global core.editor emacs"
                               "git config --global core.autocrlf false"
                               "git config --global status.showUntrackedFiles all")
                             " && ")))
          (store-install-ok ctx)
        (store-install-fail ctx))))

  :then
  (store-install "git-credential-oauth"
    :skip '(:system android)
    :post-install
    (lambda (ctx)
      (if (= 0 (shell-command
                (string-join '("git config --global --unset-all credential.helper"
                               "git config --global --add credential.helper \"cache --timeout 21600\""
                               "git config --global --add credential.helper oauth"
                               "git config --global github.user repelliuss")
                             " && ")))
          (store-install-ok ctx)
        (store-install-fail ctx))))

  :then
  (cfg-pkg git-timemachine
    (:after meow
      (:prepend meow-mode-state-list '(git-timemachine-mode . motion)))))
