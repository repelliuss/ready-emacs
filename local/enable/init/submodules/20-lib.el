;;; 20-lib.el -*- lexical-binding: t; -*-

(defmacro @add-hook-transient (hook fn)
  (let ((transient-fn (gensym (concat "transient-" (symbol-name (cadr fn)) "-g"))))
    `(add-hook ,hook
	       (defun ,transient-fn ()
		 (funcall ,fn)
		 (remove-hook ,hook #',transient-fn)))))

(defmacro @funcall-consider-daemon (fn)
  (if (daemonp)
      `(@add-hook-transient 'server-after-make-frame-hook ,fn)
    `(funcall ,fn)))

(defun @theme-load-if-preferred (theme light dark)
  (when (or (not @theme-preferred) (eq @theme-preferred theme))
    (setq @theme-default-light light
	  @theme-default-dark dark)
    (if (eq @theme-preferred-bg 'light)
	(load-theme light 'no-confirm)
      (load-theme dark 'no-confirm))))
