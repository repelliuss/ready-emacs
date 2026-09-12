;;; async.el -*- lexical-binding: t; -*-

(cfg-pkg async)

(defun rps-async (start &optional finish)
  (let ((cur-load-path load-path))
    (async-start
     (lambda ()
       (setq load-path cur-load-path)
       (funcall start))
     finish)))
