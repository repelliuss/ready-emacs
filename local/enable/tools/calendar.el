;;; calendar.el -*- lexical-binding: t; -*-

(defun rps-run-casual-calendar ()
  (run-at-time 0 0
   (lambda ()
     (casual-calendar)
     (setq-local mode-line-format nil))))

(cfg-pkg casual
  (:bind rps-keymap-open
         "c" #'calendar)

  (:hook-to 'calendar-mode #'rps-run-casual-calendar)

  (:after calendar
    (:bind calendar-mode-map
           "?" #'casual-calendar)
    (:opt calendar-mark-holidays-flag t)))

