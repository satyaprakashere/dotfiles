(setq mac-command-key-is-meta nil)
(setq mac-option-key-is-meta t)
(setq mac-option-modifier 'meta)
(setq mac-command-modifier nil)

(require 'linum-relative)
(linum-relative-on)
(linum-relative-in-helm-p)

;----------------[Auto Save]--------------------------------;
;; (defvar emacs-autosave-directory
;;   (concat user-emacs-directory "autosaves/")
;;   "This variable dictates where to put auto saves. It is set to a
;;   directory called autosaves located wherever your .emacs.d/ is
;;   located.")
(setq backup-directory-alist
	`(("." . ,(concat user-emacs-directory "backups"))))



;--------------[Smart-mode-line settings]--------------------;
(require 'cl)
(require 'powerline)
(require 'powerline-evil)
(require 'smart-mode-line)
(require 'smart-mode-line-powerline-theme)
(powerline-evil-vim-theme)
(require 'airline-themes)
(load-theme 'airline-dark t)
(setq powerline-arrow-shape 'arrow)
(setq powerline-default-separator 'arrow)
(set-face-attribute 'mode-line nil
                    :foreground "#FFFFFF"
                    :background "#353535"
                    :box nil)
(setq sml/no-confirm-load-theme t)
(setq sml/theme 'respectful)
(sml/setup)

;----------------[Evil-Leader]-------------------------------
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

;---------------[Evil-nerd-commenter]--
; Vim key bindings
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
;(evil-ex-define-cmd "wq" 'save-buffers-kill-emacs)
(define-key evil-normal-state-map (kbd "q") ":q")
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-insert-state-map (kbd "C-u")
  (lambda ()
    (interactive)
    (evil-delete (point-at-bol) (point))))
(evil-mode 1)

;;-----------------[Helm]-------------------------------------
;;; (setq package-load-list '((helm-core t) (helm t) (async t)))
;;; (package-initialize)
(require 'helm-config)
(helm-mode 1)
(recentf-mode 1)
(setq-default recent-save-file "~/.emacs.d/recentf")  
(setq helm-autoresize-mode 1)
(setq helm-autoresize-max-height 30)
(setq helm-M-x-fuzzy-match t)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-l") 'helm-recentf)
(blink-cursor-mode -1)
(define-key global-map [remap find-file] 'helm-find-files)
(define-key global-map [remap occur] 'helm-occur)
(define-key global-map [remap list-auffers] 'helm-suffers-list)
(define-key global-map [remap dabbrev-expand] 'helm-dabbrev)
(global-set-key (kbd "M-x") 'helm-M-x)
(unless (boundp 'completion-in-region-function)
  (define-key lisp-interaction-mode-map [remap completion-at-point] 'helm-lisp-completion-at-point)
  (define-key emacs-lisp-mode-map       [remap completion-at-point] 'helm-lisp-completion-at-point))

;;; -----------------------------
;;; helm-projectile
(when (package-installed-p 'helm-projectile)
  (projectile-global-mode)
  (helm-projectile-on)
  )

;;-----------[Sublimity]--
(require 'sublimity)
(require 'sublimity-scroll)
(setq sublimity-scroll-weight 10
      sublimity-scroll-drift-length 5)
(sublimity-mode 1)

;;--------------[ AucTex settins] -----------------------------------;
;; locating latex executables
;;(getenv "PATH")
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

(require 'flymake)
(defun flymake-get-tex-args (file-name)
(list "pdflatex"
(list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))

(add-hook 'LaTeX-mode-hook 'flymake-mode)
(setq ispell-program-name "aspell") ; could be ispell as well, depending on your preferences
(setq ispell-dictionary "english") ; this can obviously be set to any language your spell-checking program supports

(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-buffer)
(defun turn-on-outline-minor-mode ()
(outline-minor-mode 1))

(add-hook 'LaTeX-mode-hook 'turn-on-outline-minor-mode)
(add-hook 'latex-mode-hook 'turn-on-outline-minor-mode)
(setq outline-minor-mode-prefix "\C-c \C-o") ; Or something else

(require 'tex-site)
(autoload 'reftex-mode "reftex" "RefTeX Minor Mode" t)
(autoload 'turn-on-reftex "reftex" "RefTeX Minor Mode" nil)
(autoload 'reftex-citation "reftex-cite" "Make citation" nil)
(autoload 'reftex-index-phrase-mode "reftex-index" "Phrase Mode" t)
(add-hook 'latex-mode-hook 'turn-on-reftex) ; with Emacs latex mode
(add-hook 'reftex-load-hook 'imenu-add-menubar-index)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

(setq LaTeX-eqnarray-label "eq"
LaTeX-equation-label "eq"
LaTeX-figure-label "fig"
LaTeX-table-label "tab"
LaTeX-myChapter-label "chap"
TeX-auto-save t
TeX-newline-function 'reindent-then-newline-and-indent
TeX-parse-self t
TeX-style-path
'("style/" "auto/"
"/usr/share/emacs21/site-lisp/auctex/style/"
"/var/lib/auctex/emacs21/"
"/usr/local/share/emacs/site-lisp/auctex/style/")
LaTeX-section-hook
'(LaTeX-section-heading
LaTeX-section-title
LaTeX-section-toc
LaTeX-section-section
LaTeX-section-label))


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

;; now let's call this function from c/c++ hooks
;(add-hook 'c++-mode-hook 'my:flymake-google-init)
;(add-hook 'c-mode-hook 'my:flymake-google-init)

;; start google-c-style with emacs
;(require 'google-c-style)
;(add-hook 'c-mode-common-hook 'google-set-c-style)
;(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;;; turn on Semantic
;;(semantic-mode 1)
;;; let's define a function which adds semantic as a suggestion backend to auto complete
;;; and hook this function to c-mode-common-hook
;;(defun my:add-semantic-to-autocomplete() 
  ;;(add-to-list 'ac-sources 'ac-source-semantic)
;;)
;;(add-hook 'c-mode-common-hook 'my:add-semantic-to-autocomplete)
;;; turn on ede mode 
;;(global-ede-mode 1)
;;; create a project for our program.
;;(ede-cpp-root-project "my project" :file "~/demos/my_program/src/main.cpp"
              ;;:include-path '("/../my_inc"))
;;; you can use system-include-path for setting up the system header file locations.
;;; turn on automatic reparsing of open buffers in semantic
;;(global-semantic-idle-scheduler-mode 1)

;;; set LD_LIBRARY_PATH 
;;(setenv "LD_LIBRARY_PATH" "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/")
;;; load irony-mode
;;( add-to-list 'load-path (expand-file-name "~/.emacs.d/irony-mode/elisp/"))
;;(require 'irony)
;;; also enable ac plugin
;;(irony-enable 'ac)
;;; define a function to start irony mode for c/c++ modes
;;(defun my:irony-enable()
  ;;(when (member major-mode irony-known-modes)
    ;;(irony-mode 1)))
;;(add-hook 'c++-mode-hook 'my:irony-enable)
;;(add-hook 'c-mode-hook 'my:irony-enable)

;----------------[Markdown settings]------------------------------;
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
   "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
(setq markdown-split-window-direction 'right)

(provide 'config-others)
