;;; 20-lib.el -*- lexical-binding: t; -*-

(defmacro @add-hook-transient (hook fn)
  "Add FN to HOOK where FN will be removed after first run of HOOK."
  (let ((transient-fn (gensym (concat "transient-" (symbol-name (cadr fn)) "-g"))))
    `(add-hook ,hook
	       (defun ,transient-fn ()
		 (funcall ,fn)
		 (remove-hook ,hook #',transient-fn)))))

(defmacro @funcall-consider-daemon (fn)
  "Unless current session is daemon call FN, otherwise call it after first frame."
  (if (daemonp)
      `(@add-hook-transient 'server-after-make-frame-hook ,fn)
    `(funcall ,fn)))

(defun @theme-load-if-preferred (theme light dark)
  "Load and save background variants if @THEME-PREFERRED is EQ to THEME."
  (when (or (not @theme-preferred) (eq @theme-preferred theme))
    (setq @theme-default-light light
	  @theme-default-dark dark)
    (if (eq @theme-preferred-bg 'light)
	(load-theme light :no-confirm)
      (load-theme dark :no-confirm))))

(defun @make-local-prefix (&optional key)
  (concat @leader-local-prefix (if key " ") key))
