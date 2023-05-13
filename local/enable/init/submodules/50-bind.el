;;; 50-bind.el -*- lexical-binding: t; -*-

(@setup bind
  (:elpaca bind
	   :host github
	   :repo "repelliuss/bind"
	   :files (:defaults "extensions/bind-setup.el"))
  (:also-load bind-setup)
  (bind-setup-integrate :bind))

(elpaca-wait)
