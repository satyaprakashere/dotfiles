;-----------------[Window display settings]-----------------;
(when (not (display-graphic-p))
  (menu-bar-mode -1))
(when (window-system)
  (set-frame-position (selected-frame) 350 0)
  (set-frame-width (selected-frame) 120)
  (set-frame-height (selected-frame) 60))

;; activate installed packages
(package-initialize)

;-----------------[Theme Settings]--------------------------;
(require 'solarized-theme)
(load-theme 'solarized-light t)
(set-default-font "Monaco 12")

;--------------[Package Management]--------------------------;
(require 'package)

;; Add melpa package source when using package list
(unless package--initialized
  (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                           ("melpa-stable" . "http://melpa.milkbox.net/packages/")
                           ("melpa" . "http://melpa.org/packages/")
                           ;("marmalade" . "http://marmalade-repo.org/packages/")
                           ("org" . "http://orgmode.org/elpa/")))

  ;; optimization, no need to activate all the packages so early
  (setq package-enable-at-startup nil)
  (package-initialize 'noactivate))

; proxy settings
;(setq url-proxy-services
   ;'(("no_proxy" . "^\\(localhost\\|10.*\\)")
     ;("http" . "10.3.100.207:8080")
     ;("https" . "10.3.100.207:8080")))

;(setq package-enable-at-startup nil)

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.
    Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     ;; (package-installed-p 'evil)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(ensure-package-installed
  'airline-themes
  'flymake
  'flymake-google-cpplint
  'google-c-style
  'auctex
  'helm
  'helm-projectile
  'evil
  'evil-leader
  'powerline-evil
  'evil-nerd-commenter
  'auto-complete
  'auto-complete-c-headers
  'iedit
  'multiple-cursors
  'latex-pretty-symbols
  'rainbow-delimiters
  'yasnippet
  'haskell-mode
  'magit
  'minimap
  'sublimity
  'powerline
  'solarized-theme
  'smart-mode-line
  'smart-mode-line-powerline-theme)

;; activate installed packages
(package-initialize)

;-----------------[Window display settings]-----------------;
(setq initial-scratch-message nil)
(setq inhibit-startup-message t)
(toggle-scroll-bar 0) 
(tool-bar-mode -1)
(mouse-wheel-mode -1)
(global-hl-line-mode 1)
(global-linum-mode t)
(fset 'yes-or-no-p 'y-or-n-p)

(global-set-key [wheel-up] 'ignore)
(global-set-key [wheel-down] 'ignore)
(global-set-key [double-wheel-up] 'ignore)
(global-set-key [double-wheel-down] 'ignore)
(global-set-key [triple-wheel-up] 'ignore)
(global-set-key [triple-wheel-down] 'ignore)

(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

(add-to-list 'default-frame-alist '(left . 350))
(add-to-list 'default-frame-alist '(top . 0))
(add-to-list 'default-frame-alist '(height . 60))
(add-to-list 'default-frame-alist '(width . 120))

;----------------[Auto Save]--------------------------------;
(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/")
  "This variable dictates where to put auto saves. It is set to a
  directory called autosaves located wherever your .emacs.d/ is
  located.")



;--------------[Smart-mode-line settings]--------------------;
;(require 'powerline)
;(require 'powerline-evil)
;(powerline-evil-vim-theme)
;(require 'airline-themes)
;(load-theme 'airline-solarized-alternate-gui t)
(setq powerline-arrow-shape 'curve)
(setq sml/no-confirm-load-theme t)
(setq sml/theme 'light)
(sml/setup)

;----------------[Evil-Leader]-------------------------------
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

;---------------[Evil-nerd-commenter]--
;; Vim key bindings
(evil-leader/set-key
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
  "\\" 'evilnc-comment-operator ; if you prefer backslash key
)
;----------------[Evil Mode]----------------------------------
(require 'evil)
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-insert-state-map (kbd "C-u")
  (lambda ()
    (interactive)
    (evil-delete (point-at-bol) (point))))
(evil-mode 1)

;-----------------[Helm]-------------------------------------
;; (setq package-load-list '((helm-core t) (helm t) (async t)))
;; (package-initialize)
(require 'helm-config)
(helm-mode 1)
(recentf-mode 1)
(setq-default recent-save-file "~/.emacs.d/recentf")  
(setq helm-autoresize-mode 1)
(setq helm-autoresize-max-height 30)
(setq helm-M-x-fuzzy-match t)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "\C-p") 'helm-recentf)
(blink-cursor-mode -1)
(define-key global-map [remap find-file] 'helm-find-files)
(define-key global-map [remap occur] 'helm-occur)
(define-key global-map [remap list-buffers] 'helm-buffers-list)
(define-key global-map [remap dabbrev-expand] 'helm-dabbrev)
(global-set-key (kbd "M-x") 'helm-M-x)
(unless (boundp 'completion-in-region-function)
  (define-key lisp-interaction-mode-map [remap completion-at-point] 'helm-lisp-completion-at-point)
  (define-key emacs-lisp-mode-map       [remap completion-at-point] 'helm-lisp-completion-at-point))

;;; -----------------------------
;;; helm-projectile
;(when (package-installed-p 'helm-projectile)
  ;(projectile-global-mode)
  ;(helm-projectile-on)
  ;)

;-----------[Sublimity]--
;(require 'sublimity)
;(require 'sublimity-scroll)
;(setq sublimity-scroll-weight 10
      ;sublimity-scroll-drift-length 5)
;(sublimity-mode 1)

;--------------[ AucTex settins] -----------------------------------;
; locating latex executables
;(getenv "PATH")
(setenv "PATH"
        (concat
          "/Library/TeX/texbin/" ":"
          "/usr/local/bin" ":"
          (getenv "PATH")))

(require 'preview)
(require 'latex-pretty-symbols)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)
(setq TeX-PDF-mode t)
(setq preview-gs-command "/usr/local/bin/gs")

;(require 'flymake)
;(defun flymake-get-tex-args (file-name)
;(list "pdflatex"
;(list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))

;(add-hook 'LaTeX-mode-hook 'flymake-mode)
;(setq ispell-program-name "aspell") ; could be ispell as well, depending on your preferences
;(setq ispell-dictionary "english") ; this can obviously be set to any language your spell-checking program supports

;(add-hook 'LaTeX-mode-hook 'flyspell-mode)
;(add-hook 'LaTeX-mode-hook 'flyspell-buffer)
;(defun turn-on-outline-minor-mode ()
;(outline-minor-mode 1))

;(add-hook 'LaTeX-mode-hook 'turn-on-outline-minor-mode)
;(add-hook 'latex-mode-hook 'turn-on-outline-minor-mode)
;(setq outline-minor-mode-prefix "\C-c \C-o") ; Or something else

;(require 'tex-site)
;(autoload 'reftex-mode "reftex" "RefTeX Minor Mode" t)
;(autoload 'turn-on-reftex "reftex" "RefTeX Minor Mode" nil)
;(autoload 'reftex-citation "reftex-cite" "Make citation" nil)
;(autoload 'reftex-index-phrase-mode "reftex-index" "Phrase Mode" t)
;(add-hook 'latex-mode-hook 'turn-on-reftex) ; with Emacs latex mode
;;; (add-hook 'reftex-load-hook 'imenu-add-menubar-index)
;(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

;(setq LaTeX-eqnarray-label "eq"
;LaTeX-equation-label "eq"
;LaTeX-figure-label "fig"
;LaTeX-table-label "tab"
;LaTeX-myChapter-label "chap"
;TeX-auto-save t
;TeX-newline-function 'reindent-then-newline-and-indent
;TeX-parse-self t
;TeX-style-path
;'("style/" "auto/"
;"/usr/share/emacs21/site-lisp/auctex/style/"
;"/var/lib/auctex/emacs21/"
;"/usr/local/share/emacs/site-lisp/auctex/style/")
;LaTeX-section-hook
;'(LaTeX-section-heading
;LaTeX-section-title
;LaTeX-section-toc
;LaTeX-section-section
;LaTeX-section-label))


;-------------[auto-complete seetings]---------------------------;

(require 'auto-complete)                        ; start auto-complete with emacs
(require 'auto-complete-config)                 ; do default config for auto-complete
(ac-config-default)
; let's define a function which initializes auto-complete-c-headers and gets called for c/c++ hooks
(defun my:ac-c-header-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1"))

;---------------[yasnippet settings]-----------------------------;
(require 'yasnippet)
;(yas-global-mode 1)

;----------------[iedit settings]--------------------------------;
;(require 'iedit)
(define-key global-map (kbd "C-c ;") 'iedit-mode)

;----------------[Flymake settings]------------------------------;
; start flymake-google-cpplint-load
; let's define a function for flymake initialization
(require 'flymake-google-cpplint)
(defun my:flymake-google-init () 
  (require 'flymake-google-cpplint)
  (custom-set-variables
   '(flymake-google-cpplint-command "/Users/Satya/Library/Python/2.7/lib/python/site-packages/cpplint.py"))
  (flymake-google-cpplint-load)
)

; now let's call this function from c/c++ hooks
(add-hook 'c++-mode-hook 'my:flymake-google-init)
(add-hook 'c-mode-hook 'my:flymake-google-init)

; start google-c-style with emacs
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; turn on Semantic
;(semantic-mode 1)
;; let's define a function which adds semantic as a suggestion backend to auto complete
;; and hook this function to c-mode-common-hook
;(defun my:add-semantic-to-autocomplete() 
  ;(add-to-list 'ac-sources 'ac-source-semantic)
;)
;(add-hook 'c-mode-common-hook 'my:add-semantic-to-autocomplete)
;; turn on ede mode 
;(global-ede-mode 1)
;; create a project for our program.
;(ede-cpp-root-project "my project" :file "~/demos/my_program/src/main.cpp"
              ;:include-path '("/../my_inc"))
;; you can use system-include-path for setting up the system header file locations.
;; turn on automatic reparsing of open buffers in semantic
;(global-semantic-idle-scheduler-mode 1)


