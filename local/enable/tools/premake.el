;;; premake.el -*- lexical-binding: t; -*-

(enable-when rps-user-work-p)

(cfg-pkg (:require (:elpaca premake
                              :host github
                              :repo "repelliuss/premake"
							  :protocol ssh
                              :files (:defaults "files"))))

