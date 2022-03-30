;;; project.el -*- lexical-binding: t; -*-

(bind rps/leader-map
      "p" project-prefix-map)

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist '(("p$" . "prefix") . (nil . "project"))))

(provide 'rps/editor/project)
