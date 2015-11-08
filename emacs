(if window-system
    (tool-bar-mode -1)
)

(setq inhibit-startup-message t)
(require 'package)

;; Load emacs packages and activate them
;; This must come before configurations of installed packages.
;; Don't delete this line.
(package-initialize)

;; Add melpa package source when using package list
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; set solarized dark theme
(load-theme 'solarized-dark)

;(desktop-save-mode 1)

;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time

;(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-step 1) ;; keyboard scroll one line at a time

;(defadvice handle-delete-frame (around my-handle-delete-frame-advice activate)
  ;"Hide Emacs instead of closing the last frame"
  ;(let ((frame   (posn-window (event-start event)))
        ;(numfrs  (length (frame-list))))
    ;(if (> numfrs 1)
      ;ad-do-it
      ;(do-applescript "tell application \"System Events\" to tell process \"Emacs\" to set visible to false"))))

(substitute-key-definition 'delete-window 'delete-frame global-map)

