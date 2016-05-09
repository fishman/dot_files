;; (setq-default dotspacemacs-configuration-layers '(themes-megapack python company-mode))
;; (setq-default dotspacemacs-configuration-layers '(themes-megapack python auto-completion fasd git))
(setq-default dotspacemacs-configuration-layers '(themes-megapack
                                                  markdown
                                                  python
                                                  ruby



                                                  auto-completion
                                                  c-c++
                                                  flycheck
                                                  flyspell
                                                  rust
                                                  shell
                                                  fasd
                                                  evil-commentary
                                                  ycmd
                                                  dash
                                                  ansible
                                                  git
                                                  github
                                                  version-control
                                                  latex

                                                  erlang
                                                  elixir
                                                  (org :variables
                                                       org-enable-github-support t)
                                                 ))

;; git
;; (git :variables
;;      git-magit-status-fullscreen t
;;      git-enable-github-support t
;;      git-gutter-use-fringe t)

(setq markdown-command "~/git/gh-markdown-cli/bin/mdown")
(setq markdown-css-path "/home/timebomb/.emacs.d/github.css")
(defun dotspacemacs/user-config ()

 
(setq org-log-done t)
;; (setq org-agenda-files (list "~/org/work.org"
;;                              "~/org/school.org" 
;;                              "~/org/home.org"))

(setq org-agenda-files '("~/Documents/org"))

  "This is were you can ultimately override default Spacemacs configuration.
 This function is called at the very end of Spacemacs initialization."
  ;; use O as org global bindings
  (evil-leader/set-key
    "Oa" 'org-agenda
    "Og" 'helm-org-agenda-files-headings
    "Oo" 'org-clock-out
    "Oc" 'org-capture
    "OC" 'helm-org-capture-templates ;requires templates to be defined.
    "Ol" 'org-store-link)
  (linum-relative-toggle)

  "Configuration function.
   This function is called at the very end of Spacemacs initialization after
   layers configuration."
  (setq initial-major-mode 'org-mode)
  (setq org-directory "~/org")
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  (setq org-mobile-inbox-for-pull "~/org/flagged.org")
  (setq org-mobile-directory "~/Dropbox/MobileOrg")
  (setq org-agenda-files '("~/org"))
  (setq dotspacemacs-version-check-enable 'nil)

  (setq-default
   ;; js2-mode
   js2-basic-offset 2
   ;; web-mode
   css-indent-offset 2
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-code-indent-offset 2
   web-mode-attr-indent-offset 2)
  (with-eval-after-load 'web-mode
    (add-to-list 'web-mode-indentation-params '("lineup-args" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-concats" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-calls" . nil))) 
)
;; (setq-default git-enable-github-support t)
;; (setq-default git-magit-status-fullscreen t)
;; (setq powerline-default-separator 'arrow))
;; (setq powerline-default-separator 'nil))


(setq magit-repo-dirs '("~/git/"))
(setq-default dotspacemacs-themes '(smyx))
;; (setq-default
 ;; ;; Default theme applied at startup
;; (setq-default dotspacemacs-default-theme 'zenburn)

(setq-default dotspacemacs-default-font '("Source Code Pro"
                                          :size 24
                                          :weight normal
                                          :width normal
                                          :powerline-scale 1.1))

(defun dotspacemacs/config ()
  "Configuration function.
   This function is called at the very end of Spacemacs initialization after
   layers configuration."
   (setq initial-major-mode 'org-mode)
   (setq org-directory "~/org")
   (setq org-default-notes-file (concat org-directory "/notes.org"))
   (setq org-mobile-inbox-for-pull "~/org/flagged.org")
   (setq org-mobile-directory "~/Dropbox/MobileOrg")
   (setq org-agenda-files '("~/org"))
)


(defun dotspacemacs/init ()
  ;;  (spacemacs/load-or-install-package 'sx t)
  ;;  (require 'sx-load)
  ;; (setq org-bullets-bullet-list '("■" "◆" "▲" "▶"))
  (setq-default evil-escape-key-sequence "jk")
  (setq paradox-github-token "7693224097823e845d1f39f82ba5fea5a7ae5531")
  (setq-default ycmd-server-command '("python2" "~/.vim/bundle/YouCompleteMe/third_party/ycmd/ycmd"))
  (global-linum-mode 1)
  (add-hook 'c-mode-hook 'ycmd-mode))

 ;;  smyx -> flatland -> stekene-dark ->  firebelly -> subatomic
 ;; wombat
 ;;  nilfheim background color, irblacks green, hemisu green
;; flatland theme issues: 1. search highlight is to bright 
;; 2. 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(send-mail-function (quote mailclient-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil))))
 '(company-tooltip-common ((t (:inherit company-tooltip :weight bold :underline nil))))
 '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :weight bold :underline nil)))))
