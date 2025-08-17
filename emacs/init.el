;; This is the Aquamacs Preferences file.
;; Add Emacs-Lisp code here that should be executed whenever
;; you start Aquamacs Emacs. If errors occur, Aquamacs will stop
;; evaluating this file and print errors in the *Messages* buffer.
;; Use this file in place of ~/.emacs (which is loaded as well.)

;; Example Aquamacs Preferences.el
;; Set default font
(set-face-attribute 'default nil :family "Menlo" :height 140)

;; Set custom frame title
(setq frame-title-format '("%b - Aquamacs"))

;; Show line numbers
(global-display-line-numbers-mode t)

;; Customize backup file directory
(setq backup-directory-alist '(("." . "~/.emacs-backups")))

;; Enable ido-mode for flexible buffer and file navigation
(ido-mode t)

(tool-bar-mode -1)


(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; ==========================================================
;; 1. PACKAGE MANAGEMENT (The Foundation)
;; ==========================================================
;(require 'package)
;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;(package-initialize)

;; Install 'use-package' if not present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; ==========================================================
;; 2. THE VIM EXPERIENCE (Evil Mode)
;; ==========================================================
(use-package evil
  :init
  (setq evil-want-keybinding nil) ;; Required for evil-collection
  :config
  (evil-mode 1)
  ;; Make j/k move by visual lines (better for wrapped text)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line))

;; Adds Vim bindings to help windows, magit, etc.
(use-package evil-collection
  :after evil
  :config (evil-collection-init))

;; ==========================================================
;; 3. THE VS CODE EXPERIENCE (UI & Search)
;; ==========================================================

;; Doom Themes: Modern, dark, and high-contrast
(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;; Vertico: A clean, vertical search UI (like VS Code Command Palette)
(use-package vertico
  :init (vertico-mode))

;; Marginalia: Adds descriptions to your search (file sizes, etc.)
(use-package marginalia
  :init (marginalia-mode))

;; Orderless: Type "mod pref" to find "modern-preferences" (Fuzzy Search)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; ==========================================================
;; 4. ZED-STYLE SPEED & UTILITY
;; ==========================================================

;; Projectile: Project management (Cmd-Shift-P style)
(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

;; Magit: The best Git interface in existence
(use-package magit)

;; Simple UI cleanups
(setq inhibit-startup-message t)
(column-number-mode t)
(global-display-line-numbers-mode t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil)
 '(package-vc-selected-packages
   '((odin-mode :vc-backend Git :url
      "https://git.sr.ht/~mgmarlow/odin-mode"))))
(custom-set-faces)
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
;(package-vc-install "https://git.sr.ht/~mgmarlow/odin-mode")
(use-package odin-mode
  :bind (:map odin-mode-map
         ("C-c C-r" . 'odin-run-project)
         ("C-c C-c" . 'odin-build-project)
         ("C-c C-t" . 'odin-test-project)))
