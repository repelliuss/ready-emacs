;;; quiet.el -*- lexical-binding: t; -*-

(advice-add #'display-startup-echo-area-message :override #'ignore)

(provide 'rdy/ux/quiet)
