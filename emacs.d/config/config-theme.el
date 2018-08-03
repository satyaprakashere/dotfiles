;;;; ~/.emacs.d/jhk-colors.el
;;;;
;;;; Set up emacs colors. Currently, this is built off the the
;;;; excellent solarized theme.

(require 'solarized-theme)
(load-theme 'solarized-dark t)
(setq default-frame-alist '((font . "Monaco\ for\ Powerline")))

(provide 'config-theme)
