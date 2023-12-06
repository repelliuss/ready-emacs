;;; 20-lib.el -*- lexical-binding: t; -*-

(defmacro ~add-hook-transient (hook fn)
  "Add FN to HOOK where FN will be removed after first run of HOOK."
  (let ((transient-fn (gensym (concat "transient-" (symbol-name (cadr fn)) "-g"))))
    `(add-hook ,hook
	       (defun ,transient-fn ()
		 (funcall ,fn)
		 (remove-hook ,hook #',transient-fn)))))

(defmacro ~funcall-consider-daemon (fn)
  "Unless current session is daemon call FN, otherwise call it after first frame."
  (if (daemonp)
      `(~add-hook-transient 'server-after-make-frame-hook ,fn)
    `(funcall ,fn)))

(defun ~theme-register (theme light dark)
  "Add theme to theme registry."
  (add-to-list '~theme-register (cons theme (cons light dark))))

(defun ~theme-load-preferred ()
  "Load preferred theme if registered."
  (when-let ((theme (alist-get ~theme-preferred ~theme-register)))
    (setq ~theme-default-light (car theme)
	  ~theme-default-dark (cdr theme))
    (if (eq ~theme-preferred-bg 'light)
	(load-theme ~theme-default-light :no-confirm)
      (load-theme ~theme-default-dark :no-confirm))))

(defun ~make-local-prefix (&optional key)
  (concat ~key-leader-prefix " " ~key-local-leader-prefix (if key " ") key))

(defun ~press-thing-at-point ()
  (interactive)
  (let* ((field  (get-char-property (point) 'field))
         (button (get-char-property (point) 'button))
         (doc    (get-char-property (point) 'widget-doc))
         (widget (or field button doc)))
    (cond
     ((and widget
           (or (and (symbolp widget)
                    (get widget 'widget-type))
               (and (consp widget)
                    (get (widget-type widget) 'widget-type))))
      (widget-button-press (point)))
     ((and (button-at (point)))
      (push-button)))))
