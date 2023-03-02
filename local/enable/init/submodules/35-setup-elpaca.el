(require 'setup)
(require 'elpaca)

(setup-define :elpaca
  (lambda (recipe)
    `(unless (elpaca ',recipe)
       ,(setup-quit)))
  :documentation
  "Install RECIPE with `elpaca'.
This macro can be used as HEAD, and will replace itself with the
first RECIPE's package."
  :repeatable t
  :shorthand (lambda (sexp)
               (let ((recipe (cadr sexp)))
                 (if (consp recipe)
                     (car recipe)
                   recipe))))
