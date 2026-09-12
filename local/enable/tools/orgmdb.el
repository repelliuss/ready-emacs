;;; orgmdb.el -*- lexical-binding: t; -*-

(cfg-pkg orgmdb
  (:after org
    (:bind org-mode-map (:locally "m" #'orgmdb-act)))
  (:opt orgmdb-fill-property-list '(genre
                                    runtime
                                    released
                                    director
                                    writer
                                    production
                                    actors
                                    language
                                    country
                                    awards
                                    plot
                                    imdb-id)
        orgmdb-poster-folder (:mkdir rps-dir-local "org" "orgmdb" "poster")))
