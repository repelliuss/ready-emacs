;;; jinx.el -*- lexical-binding: t; -*-

(defun rps-grammar-find-repetitions ()
  "Find repetitions of words with at most 100 words between them."
  (interactive)
  (occur "\\<\\(\\w\\{5,\\}\\)\\>\\(?:\\(?:\\W*\\<\\w+\\>\\)\\{0,100\\}\\W*\\1\\)+"))

(defun rps-grammar-highlight-repetitions ()
  "Find repetitions of words with at most 100 words between them."
  (interactive)
  (highlight-regexp "\\<\\(\\w\\{5,\\}\\)\\>\\(?:\\(?:\\W*\\<\\w+\\>\\)\\{0,100\\}\\W*\\1\\)+"))

(cfg-pkg jinx
  (:autoload jinx-mode)
  (:opt jinx-languages "en_US tr_TR")

  (:hook-into text-mode prog-mode conf-mode)

  (:after-this
    (:bind (bind-global-map)
      "M-$" #'jinx-correct
      "C-M-$" #'jinx-languages))

  (:after vertico-multiform
    (:prepend vertico-multiform-categories
          '(jinx grid (vertico-grid-annotate . 20))))

  (store-thread
    (store-install "enchant2-devel"
      :pacman '(:name "mingw-w64-x86_64-enchant" :system windows)
      :pkg '(:name "enchant"))
    
    :then
    (store-install "enchant2-hunspell"
      :skip '(:system android))

    :then
    (store-install "hunspell"
      :pacman '(:name "mingw-w64-x86_64-hunspell" :system windows))

    :then
    (store-install "hunspell-en_US"
      :pacman '(:name "mingw-w64-x86_64-hunspell-en" :system windows)
      :pkg '(:name "hunspell-en-us"))

    :then
    (store-install "hunspell-tr"
      :skip '(:system android)
      :pacman '(:name "mingw-w64-x86_64-hunspell-tr" :system windows))))
