;; This is the Aquamacs Preferences file.
;; Add Emacs-Lisp code here that should be executed whenever
;; you start Aquamacs Emacs. If errors occur, Aquamacs will stop
;; evaluating this file and print errors in the *Messags* buffer.
;; Use this file in place of ~/.emacs (which is loaded as well.)

(when (featurep 'aquamacs)
  (raise-frame))

(cond ((string= "mac" window-system)
  (setq default-frame-alist '((top . 23) (left . 0) (width . 150) (height . 50)))
))

(add-to-list 'load-path "~/.emacs.d")

;; Color theme
(require 'color-theme)
(color-theme-initialize)
(load-file '"~/.emacs.d/zenburn.el")
(color-theme-zenburn)
; (require 'twilight)
; (defun my-emacs-startup-hook ()
 ; (load-file '"~/.emacs.d/twilight.el"))

; (setq initial-frame-plist '(top 0 left 0 width 120 height 67))

;; C++ and C mode...
(defun my-c++-mode-hook ()
  (setq tab-width 4)
  (define-key c++-mode-map "\C-m" 'reindent-then-newline-and-indent)
  (define-key c++-mode-map "\C-ce" 'c-comment-edit)
  (setq c++-auto-hungry-initial-state 'none)
  (setq c++-delete-function 'backward-delete-char)
  (setq c++-tab-always-indent t)
  (setq c-indent-level 4)
  (setq c-continued-statement-offset 4)
  (setq c++-empty-arglist-indent 4))

(defun my-c-mode-hook ()
  (setq tab-width 4)
  ; (define-key c-mode-map "\C-m" 'reindent-then-newline-and-indent)
  (define-key c-mode-map "\C-m" 'newline-and-indent)
  (define-key c-mode-map "\C-ce" 'c-comment-edit)
  (setq c-auto-hungry-initial-state 'none)
  (setq c-delete-function 'backward-delete-char)
  (setq c-tab-always-indent t)
;; BSD-ish indentation style
  (setq c-indent-level 4)
  (setq c-continued-statement-offset 4)
  (setq c-brace-offset -4)
  (setq c-argdecl-indent 0)
  (setq c-label-offset -4))

;; Perl mode
(defun my-perl-mode-hook ()
  (setq tab-width 4)
  ; (define-key c++-mode-map "\C-m" 'reindent-then-newline-and-indent)
  (define-key c++-mode-map "\C-m" 'newline-and-indent)
  (setq perl-indent-level 4)
  (setq perl-continued-statement-offset 4))

; Moxley's php-mode customizations
(require 'php-mode)
(defun my-php-mode-common-hook ()
  ;; my customizations for php-mode
  (setq tab-width 4)
  (define-key c-mode-map "\C-m" 'newline-and-indent)
  (setq c-basic-offset 4)
  (c-set-offset 'topmost-intro-cont 4)
  (c-set-offset 'class-open 0)
  (c-set-offset 'inline-open 0)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'arglist-intro '+)
  )
(defun pear-php-mode-hook ()
  (setq tab-width 4
        c-basic-offset 4
        indent-tabs-mode
      (string-match "\.php$" (buffer-file-name))))

(add-hook 'php-mode-hook 'pear-php-mode-hook)

; ;; Add all of the hooks...
(add-hook 'c++-mode-hook 'my-c++-mode-hook)
(add-hook 'c-mode-hook 'my-c-mode-hook)
; (add-hook 'scheme-mode-hook 'my-scheme-mode-hook)
; (add-hook 'emacs-lisp-mode-hook 'my-lisp-mode-hook)
; (add-hook 'lisp-mode-hook 'my-lisp-mode-hook)
(add-hook 'perl-mode-hook 'my-perl-mode-hook)
(add-hook 'php-mode-hook 'pear-php-mode-hook)
(add-hook 'php-mode-hook 'my-php-mode-common-hook)
; (add-hook 'emacs-startup-hook 'my-emacs-startup-hook)

;;; VIPER MODE
;; voir ~/.viper. Activer viper :
(setq viper-mode t)                ; enable Viper at load time
(setq viper-ex-style-editing nil)  ; can backspace past start of insert / line
(require 'viper)                   ; load Viper
(require 'vimpulse)                ; load Vimpulse
(setq woman-use-own-frame nil)     ; don't create new frame for manpages
(setq woman-use-topic-at-point t)  ; don't prompt upon K key (manpage display)
; (require 'redo)
; (require 'rect-mark)

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/snippets")

(add-to-list 'load-path "~/.emacs.d/vendor/textmate.el")
(require 'textmate)
(textmate-mode)
;; Load CEDET
(load-file "~/.emacs.d/cedet-1.0pre4/common/cedet.el")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following:

;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
; (semantic-load-enable-code-helpers)
(semantic-load-enable-excessive-code-helpers)

;; * This enables even more coding tools such as the nascent intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;; (semantic-load-enable-guady-code-helpers)

;; * This turns on which-func support (Plus all other code helpers)
;; (semantic-load-enable-excessive-code-helpers)

;; This turns on modes that aid in grammar writing and semantic tool
;; development.  It does not enable any other features such as code
;; helpers above.
;; (semantic-load-enable-semantic-debugging-helpers)
; (add-to-list 'load-path "~/.emacs.d/ecb")
; (require 'ecb)
(require 'eassist)

(defun my-c-mode-cedet-hook ()
  ; (local-set-key "." 'semantic-complete-self-insert)
  ; (local-set-key ">" 'semantic-complete-self-insert)
  (local-set-key "\C-ct" 'eassist-switch-h-cpp)
  (local-set-key "\C-xt" 'eassist-switch-h-cpp)
  (local-set-key "\C-c\C-r" 'semantic-symref)
  )
(add-hook 'c-mode-common-hook 'my-c-mode-cedet-hook)


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-auto-activate t)
 '(ecb-options-version "2.33beta2")
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

