;; Minimal Steel Helix Configuration
;; Test Steel integration with both console output and file logging

(require-builtin steel/random as rand::)

(displayln "=== Steel Configuration Loading ===")

;; Basic Steel functionality tests
(displayln "✓ Steel scripting engine: ACTIVE")

(define test-data '("Steel" "integration" "test"))
(displayln (string-append "✓ Data structures: " (apply string-append test-data)))

(define random-test (rand::rng->gen-range 1 100))
(displayln (string-append "✓ Random generation: " (number->string random-test)))

;; Theme configuration
(define available-themes '("rose_pine_moon" "catppuccin_macchiato" "dracula" "gruvbox"))
(define selected-theme (list-ref available-themes (rand::rng->gen-range 0 (length available-themes))))
(displayln (string-append "✓ Selected theme: " selected-theme))

;; Steel status function
(define (steel-status)
  "Display current Steel integration status"
  (displayln "\n=== Steel Integration Status ===")
  (displayln "✓ Steel scripting: ACTIVE")
  (displayln "✓ Random functions: Working")
  (displayln "✓ String manipulation: Working") 
  (displayln "✓ List processing: Working")
  (displayln (string-append "✓ Current theme target: " selected-theme))
  (displayln "\nNote: Advanced Helix integration depends on context"))

;; File logging function (for Helix debugging)
(define (write-steel-log msg)
  "Write Steel status to log file"
  (with-handler
    (lambda (e) 
      (displayln "Note: File logging not available in standalone mode"))
    (with-output-to-file "/tmp/helix-steel.log"
      (lambda () 
        (displayln "=== Helix Steel Log ===")
        (displayln msg)
        (displayln (string-append "Theme target: " selected-theme))
        (displayln "Steel integration: SUCCESS"))
      #:mode 'create)))

;; Try file logging
(write-steel-log "Steel configuration loaded successfully")

;; Custom utilities
(define (random-theme)
  "Get a random theme name"
  (list-ref available-themes (rand::rng->gen-range 0 (length available-themes))))

(define (theme-info)
  "Show theme information"
  (displayln (string-append "Available themes: " (apply string-append (map (lambda (t) (string-append t " ")) available-themes))))
  (displayln (string-append "Current selection: " selected-theme)))

;; Show status
(steel-status)

;; Export functions for potential Helix command use
(provide steel-status
         random-theme  
         theme-info
         write-steel-log)

(displayln "=== Configuration Complete ===")
(displayln "In Helix: Check for custom commands or /tmp/helix-steel.log")
(displayln "Functions exported: steel-status, random-theme, theme-info")
