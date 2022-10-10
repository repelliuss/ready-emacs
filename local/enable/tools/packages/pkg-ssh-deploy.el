;;; pkg-ssh-deploy.el -*- lexical-binding: t; -*-

(use-package async)
(use-package hydra)

(use-package ssh-deploy
        :hook ((after-save . ssh-deploy-after-save)
               (find-file . ssh-deploy-find-file))
	:config
	(add-to-list 'ssh-deploy-exclude-list "\\.gitignore")
	(ssh-deploy-hydra (keys-make-local-prefix "r")))
