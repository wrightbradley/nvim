; Inject languages into mise task `run` strings.
; The `mise` filetype uses the TOML parser, so these queries mirror the TOML
; grammar but are scoped to mise files only — no custom predicate needed.

; Multiline string with shebang using env (e.g. #!/usr/bin/env python3)
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#match? @injection.language "^\"\"\"\n*#!(/\\w+)+/env\\s+\\w+") ; multiline shebang using env
  (#gsub! @injection.language "^.*#!/.*/env%s+([^%s]+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

; Multiline string with direct shebang (e.g. #!/bin/bash)
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#match? @injection.language "^\"\"\"\n*#!(/\\w+)+\s*\n") ; multiline shebang
  (#gsub! @injection.language "^.*#!/.*/([^/%s]+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

; Multiline string without shebang — default to bash
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#match? @injection.content "^\"\"\"\n*.*") ; multiline
  (#not-match? @injection.content "^\"\"\"\n*#!") ; no shebang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)

; Single-line string — default to bash
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#not-match? @injection.content "^\"\"\"") ; not multiline
  (#offset! @injection.content 0 1 0 -1) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)
