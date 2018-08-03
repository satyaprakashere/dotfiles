(tool-bar-mode -1)
(toggle-scroll-bar 0)
(when (not (display-graphic-p))
           (menu-bar-mode -1))

;(when (window-system)
  ;(set-frame-position (selected-frame) 350 0)
  ;(set-frame-width (selected-frame) 120)
  ;(set-frame-height (selected-frame) 60))

(setq initial-scratch-message nil)
(setq inhibit-startup-message t)
(global-hl-line-mode 1)
(global-linum-mode t)
(fset 'yes-or-no-p 'y-or-n-p)

;(require 'whitespace)
;(setq whitespace-style '(face empty tabs lines-tail trailing))
;(global-whitespace-mode t)

;(add-to-list 'default-frame-alist '(left . 350))
;(add-to-list 'default-frame-alist '(top . 0))
;(add-to-list 'default-frame-alist '(height . 60))
;(add-to-list 'default-frame-alist '(width . 120))

(provide 'config-window)
