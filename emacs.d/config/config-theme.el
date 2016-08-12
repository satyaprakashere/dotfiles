;;;; ~/.emacs.d/jhk-colors.el
;;;;
;;;; Set up emacs colors. Currently, this is built off the the
;;;; excellent solarized theme.

;; Enable package management with marmalade.
(require 'package)
(package-initialize)

(require 'solarized-theme)
(load-theme 'solarized-light t)
;(set-frame-font "Monaco\ for\ Powerline-12")

(provide 'config-theme)
