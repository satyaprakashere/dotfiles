(require-builtin steel/random as rand::)
(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(define themes '("acme" "default" "github_dark"))

(define (select-random lst)
  (let ([index (rand::rng->gen-range 0 (length lst))]) (list-ref lst index)))

(define (set-random-theme themes)
  (helix.theme (select-random themes)))

; (set-random-theme themes)

; (helix.theme "catppuccin_mocha")
(helix.theme "github_dark_dimmed")
