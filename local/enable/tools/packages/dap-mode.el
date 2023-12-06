;;; dap-mode.el -*- lexical-binding: t; -*-

(use-package dap-mode
  :init
  (setq dap-auto-configure-features '(locals expressions)
	dap-utils-extension-path (concat ~dir-cache "dap-mode/extension")
	dap-breakpoints-file (concat ~dir-cache "dap-mode/breakpoints")))

(use-package cc-mode
  :config
  (require 'dap-cpptools)
  ;; (require 'dap-gdb-lldb)

  (dap-register-debug-template
   "cpptools::Run 'a.exe' with 'gdb' Configuration"
   (list :type "cppdbg"
         :request "launch"
         :name "cpptools::Run Configuration"
         :MIMode "gdb"
         :program "${workspaceFolder}/a.exe"
         :cwd "${workspaceFolder}"))

  (dap-register-debug-template
   "cpptools::Run 'a.exe' with prettier 'gdb' Configuration"
   (list :type "cppdbg"
         :request "launch"
         :name "cpptools::Run Configuration"
         :MIMode "gdb"
         :program "${workspaceFolder}/a.exe"
         :cwd "${workspaceFolder}"
	 :args []
         :stopAtEntry nil
	 :externalConsole nil
	 :miDebuggerPath "C:\\msys64\\mingw64\\bin\\gdb.exe"
         :setupCommands [
			 (:description "Enable pretty-printing for gdb"
				       :text "-enable-pretty-printing"
				       :ignoreFailures t)
			 (:description "Set Disassembly Flavor to Intel"
				       :text "-gdb-set disassembly-flavor intel"
				       :ignoreFailures t)
			 ]))
  )
