(lang dune 3.9)

(using melange 0.1)

(name melange-jest)

(generate_opam_files true)

(maintainers "Javier Ch\195\161varri <javier.chavarri@gmail.com>")

(authors
 "glennsl glennsl@users.noreply.github.com"
 "Neil Kistner <neil.kistner@gmail.com>")

(source
 (github melange-community/melange-jest))

(license "MIT")

(homepage "https://github.com/melange-community/melange-jest")

(bug_reports "https://github.com/melange-community/melange-jest/issues")

(package
 (name melange-jest)
 (synopsis "Melange bindings for Jest")
 (description "Melange bindings for Jest JavaScript library.")
 (depends
  (melange
   (>= "2.0.0"))
  (reason :with-test)
  (melange-webapi :with-test)))
