;;; 20-lib.el -*- lexical-binding: t; -*-

(defmacro add-hook-transient (hook fn)
  (let ((transient-fn (gensym (concat "transient-" (symbol-name (cadr fn)) "-g"))))
    `(add-hook ,hook (defun ,transient-fn ()
			 (funcall ,fn)
			 (remove-hook ,hook #',transient-fn)))))

(defmacro funcall-consider-daemon (fn)
  (if (daemonp)
      `(add-hook-transient 'server-after-make-frame-hook ,fn)
    `(funcall ,fn)))
