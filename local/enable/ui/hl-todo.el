;;; hl-todo.el -*- lexical-binding: t; -*-

(defun rps-hl-todo-whiten-hl-todo-face (&rest _)
  (set-face-attribute 'hl-todo nil :bold t :foreground "white"))

(cfg-pkg hl-todo
  (:opt
   hl-todo-color-background t
   hl-todo-highlight-punctuation ":")

  (:hook-to 'enable-theme-functions #'rps-hl-todo-whiten-hl-todo-face)

  (:after-this
    (:opt hl-todo-keyword-faces (-map (-lambda ((key . value))
                                        (cons (format "%s\\(_[^[:blank:]:]*\\)?" key) value))
                                      (append hl-todo-keyword-faces (list (cons "CNCL" "#695500")
                                                                          (cons "WAIT" "#d0bf8f")))))
    (rps-hl-todo-whiten-hl-todo-face))

  (global-hl-todo-mode 1))

(cfg-pkg consult-todo
  (:bind rps-keymap-search
         "t" #'consult-todo
         "T" #'consult-todo-all))

