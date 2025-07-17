; extends

; SQL
; (sigil
;   (sigil_name) @_sigil_name
;   (quoted_content) @sql
; (#eq? @_sigil_name "Q"))

(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
 (#eq? @_sigil_name "SQL")
 (#set! injection.language "sql"))

(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
 (#eq? @_sigil_name "L")
 (#set! injection.language "html"))

(call target: (identifier) @_script
   (do_block
     (string (quoted_content) @injection.content))
 (#eq? @_script "script")
 (#set! injection.language "javascript"))

(call target: (identifier) @_style
   (do_block
     (string (quoted_content) @injection.content))
 (#eq? @_style "style")
 (#set! injection.language "css"))

