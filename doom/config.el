;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; If a server isn't already running, start one
(require 'server)
; (unless (server-running-p)
;   (server-start))
;; Force the GUI app to start the server immediately
;(after! server
  ;(unless (server-running-p)
    ;(server-start)))

;; Ensure the server socket is in a predictable location for the Mac
;(setq server-socket-dir (format "/tmp/emacs%d" (user-uid)))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; Maximize the frame on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
;; If you also want every NEW frame (Cmd+N) to be maximized:
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Change only the size, keeping the default font family
(setq doom-font (font-spec :size 20)
      doom-variable-pitch-font (font-spec :size 20))

;; Disable the "Do you want to quit?" confirmation prompt
(setq confirm-kill-emacs nil)

(set-popup-rule! "^\\*build-output*"
  :side 'bottom
  :size 0.35
  :select t   ; Focus the window when it opens
  :quit t     ; Pressing 'q' or 'ESC' will close it
  :ttl nil)   ; Keep the buffer alive in the background

(defun my/build-and-run-current-file ()
  (interactive)
  (if buffer-file-name
      (let ((display-buffer-alist nil)) ; Clear internal overrides
        (async-shell-command
         (concat "bash ~/dotfiles/shell/build-scripts/build_run.sh "
                 (shell-quote-argument buffer-file-name))
         "*build-output*")) ; <--- Must match the popup rule above
    (message "No file to build!")))

(map! :n "s-b" #'my/build-and-run-current-file  ; Normal mode
      :i "s-b" #'my/build-and-run-current-file) ; Insert mode

(map! :n "s-r" #'my/build-and-run-current-file  ; Normal mode
      :i "s-r" #'my/build-and-run-current-file) ; Insert mode

(defun my/close-bottom-window ()
  "Force close the build output window or any bottom popup."
  (interactive)
  (let ((build-win (get-buffer-window "*build-output*")))
    (cond (build-win
           (delete-window build-win))
          ((and (fboundp '+popup-window-p) (+popup-window-p))
           (+popup/quit))
          (t
           (let ((w (window-at (/ (frame-pixel-width) 2)
                               (- (frame-pixel-height) 15))))
             (when (and w (not (one-window-p w)))
               (delete-window w)))))))

;; Bind Super-j to close the bottom popup/panel
(map! :nv "s-j" #'my/close-bottom-window
      :i  "s-j" #'my/close-bottom-window)

;; --- Vim Alignment ---

;; Make Y behave like C and D (yank to end of line)
(setq evil-want-Y-yank-to-eol t)

(after! evil-escape
  (setq evil-escape-key-sequence "jk")
  (setq evil-escape-delay 0.15))

;; Map ; to : in normal and visual modes
(map! :nv ";" #'evil-ex)

;; Map gb to jump backward in the jump list (like Vim's <C-o>)
(map! :n "gb" #'evil-jump-backward)

;; :desc "Build current file"  "b"   #'my/build-and-run-current-file  ; Normal mode
;; Leader mappings aliases
(map! :leader
      :desc "Run current file"    "r"   #'my/build-and-run-current-file  ; Normal mode
      :desc "Close terminal dock" "j"   #'my/close-bottom-window
      :desc "Find project files"  "o"   #'projectile-find-file
      :desc "Kill buffer"         "q"   #'kill-current-buffer
      :desc "Save buffer"         "s s" #'save-buffer
      :desc "Vertical split"      "v p" #'evil-window-vsplit
      :desc "Horizontal split"    "s p" #'evil-window-split)

;; macOS (Super) Bindings
(map! :n "s-d" #'evil-window-vsplit
      :n "s-l" (if (fboundp 'consult-buffer) #'consult-buffer #'switch-to-buffer))

;; --- Language Indentation (matching Vim config) ---
(setq-default standard-indent 4)

(after! sh-script (setq sh-basic-offset 2))
(after! haskell-mode (setq haskell-indent-offset 2))
(after! python (setq python-indent-offset 2))
(after! swift-mode (setq swift-mode:basic-offset 2))

;; Rekursion/Scheme
(after! scheme (setq scheme-indent-offset 2))

;; --- Flycheck & Go Fixes ---
(defvar flycheck-error-ignore-regexps nil)
(after! flycheck
  ;; Silence golangci-lint when it fails because of missing go.mod (e.g. single file scripts)
  (add-to-list 'flycheck-error-ignore-regexps "no go files to analyze"))

;; --- Startup Behavior ---
;; Reopen the last opened file on startup
;; (add-hook 'doom-first-buffer-hook
;;           (lambda ()
;;             (when (and (not (buffer-file-name))
;;                        (fboundp 'recentf-mode)
;;                        recentf-list)
;;               (find-file (car recentf-list)))))

;; --- Frame Persistence ---
;; Do not close Emacs when closing the last frame (minimize instead)
;; (defun my/close-frame-or-minimize ()
;;   "Delete the current frame, or minimize it if it is the last one."
;;   (interactive)
;;   (if (> (length (frame-list)) 1)
;;       (delete-frame)
;;     (iconify-frame)))

;; (map! "s-w" #'my/close-frame-or-minimize)

;; Aggressively filter out autosaves and internal workspace files from recentf
(after! recentf
  (add-to-list 'recentf-exclude ".*/etc/workspaces/autosave$")
  (add-to-list 'recentf-exclude "/#.*#$")
  (add-to-list 'recentf-exclude "/\\.#.*$")
  (add-to-list 'recentf-exclude "~$")
  (recentf-cleanup))


(setq +doom-dashboard-ascii-banner-fn nil)
;; 3. Force Emacs to start in the *scratch* buffer
;; (setq initial-buffer-choice t)

;; Map q and Alt-q to close the frame (but not kill the server if running)
(map! :n "q" #'save-buffers-kill-terminal
      "M-q" #'save-buffers-kill-terminal)

(after! doom-dashboard
  (map! :map +doom-dashboard-mode-map
        :n "q" #'save-buffers-kill-terminal))
