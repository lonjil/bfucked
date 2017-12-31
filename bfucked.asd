;;;; bfucked.asd

(asdf:defsystem #:bfucked
  :description "Describe bfucked here"
  :author "Birk Hirdman <lonjil@gmail.com"
  :license "CC0"
  :depends-on (#:alexandria)
  :serial t
  :components ((:file "package")
               (:file "bfucked")))

