;;;; ~/.emacs.d/jhk-colors.el
;;;;
;;;; Set up emacs colors. Currently, this is built off the the
;;;; excellent solarized theme.

;(require 'cask)
(require 'cask "/usr/local/share/emacs/site-lisp/cask/cask.el")
(cask-initialize)

(require 'pallet)
(pallet-mode t)

(provide 'config-packages)
