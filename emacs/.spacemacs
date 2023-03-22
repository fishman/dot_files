;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(cl-defun ap/org-capture-web-page-with-eww-readable
      (&optional url
                 (filter-fns '(remove-dos-crlf  ; This function should always be first and should always be included
                               ap/org-remove-html-blocks-from-string)))
    (let* ((url (or url (ap/get-first-url-in-kill-ring)))
           (html (ap/url-html url))
           (result (ap/eww-readable html))
           (title (cdr result))
           (title-linked (org-make-link-string url title))
           (content (with-temp-buffer
                      (insert (car result))
                      ;; Convert to Org with Pandoc
                      (unless (= 0 (call-process-region (point-min) (point-max)
                                                        "pandoc" t t nil "--no-wrap"
                                                        "-f" "html" "-t" "org"))
                        (error "Pandoc failed."))
                      ;; Demote page headings in capture buffer to below the
                      ;; top-level Org heading and "Article" 2nd-level heading
                      (save-excursion
                        (goto-char (point-min))
                        (while (re-search-forward (rx bol (1+ "*") (1+ space)) nil t)
                          (beginning-of-line)
                          (insert "**")
                          (end-of-line)))
                      (buffer-string)))
           (timestamp (format-time-string (concat "[" (substring (cdr org-time-stamp-formats) 1 -1) "]"))))
      (when filter-fns
        (dolist (fn filter-fns)
          (setq content (funcall fn content))))
      (concat title-linked " :website:\n\n" timestamp "\n\n** Article\n\n" content)))

(defun remove-dos-crlf (&optional s)
  "Remove all DOS CRLF (^M) in buffer or in string S."
  (interactive)
  (if s
      (replace-regexp-in-string (string ?\C-m) "" s
                                'fixedcase 'literal)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward (string ?\C-m) nil t)
        (replace-match "")))))

(defun ap/org-remove-html-blocks-from-string (s)
    "Remove \"#+BEGIN_HTML...#+END_HTML\" blocks from Org-formatted string S."
    (replace-regexp-in-string (rx (optional "\n") "#+BEGIN_HTML" (minimal-match (1+ anything)) "#+END_HTML" (optional "\n"))
                              "" s 'fixedcase 'literal))

(defun org-mpv-complete-link (&optional arg)
  (replace-regexp-in-string
   "^file:" "mpv:"
   (org-file-complete-link arg)
   t t))

;; (org-link-set-parameters
;;  "mpv"
;;  :follow #'mpv-play
;;  :complete #'org-mpv-complete-link)

(defun org-timer-item--mpv-insert-playback-position (fun &rest args)
  "When no org timer is running but mpv is alive, insert playback position."
  (if (and
       (not org-timer-start-time)
       (mpv-live-p))
      (mpv-insert-playback-position t)
    (apply fun args)))

(defun org-ioslide-publish-to-html (plist filename pub-dir)
  "Publish an Org file to google io slide.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  ;; Unlike to `org-latex-publish-to-latex', HTML file is generated
  ;; in working directory and then moved to publishing directory.
  (org-publish-attachment
   plist
   (org-latex-compile
    (org-publish-org-to
     'ioslide filename ".html" plist (file-name-directory filename)))
   pub-dir))


(defun init-org-agenda()
  ;; Common settings for all reviews
  (setq efs/org-agenda-review-settings
    '((org-agenda-files '("~/org"
                           "~/Nextcloud/org"
                           "~/Calendars"))
       ;; "~/org/wiki/regelwerk"
       ;; "~/org/wiki/pe" ))
       (org-agenda-show-all-dates t)
       (org-agenda-start-with-log-mode t)
       (org-agenda-start-with-clockreport-mode t)
       (org-agenda-archives-mode t)
       ;; I don't care if an entry was archived
       (org-agenda-hide-tags-regexp
         (concat org-agenda-hide-tags-regexp
           "\\|ARCHIVE"))
       ))
  ;; Show the agenda with the log turn on, the clock table show and
  ;; archived entries shown.  These commands are all the same exept for
  ;o the time period.
  (add-to-list 'org-agenda-custom-commands
               `("Rw" "Week in review"
                 agenda ""
                 ;; agenda settings
                 ,(append
                   efs/org-agenda-review-settings
                   '((org-agenda-span 'week)
                     (org-agenda-start-on-weekday 0)
                     (org-agenda-overriding-header "Week in Review"))
                   )
                 ("~/org/review/week.html")
                 ))

  (add-to-list 'org-agenda-custom-commands
               `("Rd" "Day in review"
                 agenda ""
                 ;; agenda settings
                 ,(append
                   efs/org-agenda-review-settings
                   '((org-agenda-span 'day)
                     (org-agenda-overriding-header "Week in Review"))
                   )
                 ("~/org/review/day.html")
                 ))

  (add-to-list 'org-agenda-custom-commands
               `("Rm" "Month in review"
                 agenda ""
                 ;; agenda settings
                 ,(append
                   efs/org-agenda-review-settings
                   '((org-agenda-span 'month)
                     (org-agenda-start-day "01")
                     (org-read-date-prefer-future nil)
                     (org-agenda-overriding-header "Month in Review"))
                   )
                 ("~/org/review/month.html")
                 ))
  )

      ;; (require 'ox-confluence)
(defun init-org-export()
  (eval-after-load 'ox
    '(progn
       (require 'ox-koma-letter)
       (require 'ox-deck)
       (require 'ox-extra)
       (ox-extras-activate '(ignore-headlines)))
       ))


(defun init-org-templates()
  (setq org-capture-templates
        '(("ort/checkitem" "Org Repo Checklist Item" checkitem
           (file+headline
            (ort/todo-file)
            "Checklist"))
          ("ort/todo" "Org Repo Todo" entry
           (file+headline
            (ort/todo-file)
            "Todos")
           "* TODO  %?			%T\n %i\n Link: %l\n")
          ("a" "Appointment" entry
           (file+headline "~/org/taskdiary.org" "Calendar")
           "* APPT %^{Description} %^g\n%?\nAdded: %U")
         ("n" "Notes" entry
           (file+datetree "~/org/taskdiary.org")
           "* %^{Description} %^g %?\nAdded: %U")
         ("t" "todo" entry (file+headline "~/org/TODO.org" "Tasks")
          "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n%a\n")
          ("T" "Task Diary" entry
           (file+datetree "~/org/taskdiary.org")
           "* TODO %^{Description}  %^g\n%?\nAdded: %U")
          ("j" "Journal entry" plain
           (file+otp+datetree+prompt "~/org/personal/journal.org")
           "%K - %a\n%i\n%?\n")
          ("J" "Work Journal" entry
           (file+datetree "~/org/workjournal.org")
           "** %^{Heading}")
          ("b" "capture through org protocol" entry
           (file+headline org-board-capture-file "Unsorted")
           "* %?%:description\n:PROPERTIES:\n:URL: %:link\n:END:\n\n Added %U")
          ;; (file+olp (concat org-directory "/ff-notes.org") "Web")
          ;; (file+olp "~/org/ff-notes.org" "Web")
          ;; "* %c :website:\n%U %?%:initial")
          ("v" "Capture Web site with eww-readable" entry
            (file "~/org/articles.org")
            "%(org-web-tools--url-as-readable-org)")
          ("w" "Web site" entry
            (file "~/org/ff-notes.org")
            "* %a :website:\n\n%U %?\n\n%:initial")
          ;; ("w" "Firefox Capture Template" entry
          ;;   (file+headline "ff-notes.org" "Firefox")
          ;;   "* BOOKMARKS %T\n%c\%a\n%i\n Notes:%?" :prepend t :jump-to-captured t :empty-lines-after 1 :unnarrowed t)
          ("l" "Log Time" entry
           (file+datetree "~/org/timelog.org")
           "** %U - %^{Activity}  :TIME:")))

  (eval-after-load 'ox-koma-letter
    '(progn
       (add-to-list 'org-latex-classes
                    '("my-letter"
                      "\\documentclass\{scrlttr2\}
     \\usepackage[ngerman]{babel}
     \\setkomavar{frombank}{(1234)\\,567\\,890}
     \[DEFAULT-PACKAGES]
     \[PACKAGES]
     \[EXTRA]"))
       (add-to-list 'org-latex-classes
                    '("anotherletter"
                      "\\documentclass\{scrlttr2\}
     \\usepackage[ngerman]{babel}
     \\setkomavar{frombank}{(1234)\\,567\\,890}
     \[DEFAULT-PACKAGES]
     \[PACKAGES]
     \[EXTRA]"))

       (setq org-koma-letter-default-class "my-letter")))

  (eval-after-load 'ox-cv
    '(progn
       (add-to-list 'org-latex-classes
                    '("mymoderncv"
                      "\\documentclass\{moderncv\}
\\moderncvtheme[blue]{banking}
\[NO-DEFAULT-PACKAGES]
\[NO-PACKAGES]
\[EXTRA]"))
       (setq org-export-before-parsing-hook '(ox-cv-export-parse-employment))))

  (eval-after-load 'ox-latex
    '(progn
       (setq org-latex-listings 'minted)
       (add-to-list 'org-latex-packages-alist '("" "minted"))

       ;; export single chapter
       (add-to-list 'org-latex-classes
                    '("chapter" "\\documentclass[11pt]{report}"
                      ("\\chapter{%s}" . "\\chapter*{%s}")
                      ("\\section{%s}" . "\\section*{%s}")
                      ("\\subsection{%s}" . "\\subsection*{%s}")
                      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

       (add-to-list 'org-latex-classes
                    '("titledblocks" "\\documentclass[11pt]{scrartcl}"
                      ("\\paragraph{%s}" . "\\paragraph*{%s}")))

       (add-to-list 'org-latex-classes
                    '("scrartcl" "\\documentclass[11pt]{scrartcl}"
                      ("\\section{%s}" . "\\section*{%s}")
                      ("\\subsection{%s}" . "\\subsection*{%s}")
                      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                      ("\\paragraph{%s}" . "\\paragraph*{%s}")
                      ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

       (add-to-list 'org-latex-classes
                    '("scrreprt" "\\documentclass[11pt]{scrreprt}"
                      ("\\chapter{%s}" . "\\chapter*{%s}")
                      ("\\section{%s}" . "\\section*{%s}")
                      ("\\subsection{%s}" . "\\subsection*{%s}")
                      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

       (add-to-list 'org-latex-classes
                    '("scrbook" "\\documentclass[11pt]{scrbook}"
                      ("\\part{%s}" . "\\part*{%s}")
                      ("\\chapter{%s}" . "\\chapter*{%s}")
                      ("\\section{%s}" . "\\section*{%s}")
                      ("\\subsection{%s}" . "\\subsection*{%s}")
                      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

       (add-to-list 'org-latex-classes
                    `("scrlttr2"
                      ,(concat "\\documentclass\[a4paper\]\{scrlttr2\}\n"
                               "\[NO-DEFAULT-PACKAGES]\n"
                               "\[NO-PACKAGES]\n"
                               "\\usepackage\{fixltx2e\}\n"
                               "\\usepackage\{fontspec\}\n"
                               "\\usepackage\{microtype\}\n"
                               "\\usepackage\{polyglossia\}\n"
                               "\\setdefaultlanguage[variant=british]\{english\}\n"
                               "\\usepackage\{libertine\}\n"
                               "\\usepackage\[normalem\]\{ulem\}\n"
                               "\\usepackage\{amsmath\}\n"
                               "\\usepackage\{hyperref\}\n")
                      ("\\section\{%s\}" . "\\section*\{%s\}")
                      ("\\subsection\{%s\}" . "\\subsection*\{%s\}")
                      ("\\subsubsection\{%s\}" . "\\subsubsection*\{%s\}")))


       (add-to-list 'org-latex-classes
                    `("cheatsheet"
                      , (concat
                         "\\documentclass[10pt,landscape]\{article\}\n"
                         "\[NO-DEFAULT-PACKAGES]\n"
                         "\[NO-PACKAGES]\n"
                         "\\usepackage\{multicol\}\n"
                         "\\usepackage\{calc\}\n"
                         "\\usepackage\{ifthen\}\n"
                         "\\usepackage[landscape]\{geometry\}\n"
                         "\\usepackage\{amsmath,amsthm,amsfonts,amssymb\}\n"
                         "\\usepackage\{color,graphicx,overpic\}\n"
                         "\\usepackage\{hyperref\}\n"
                         "\\ifthenelse\{\\lengthtest \{ \\paperwidth = 11in\}\}\n"
                         "\{ \\geometry\{top=.5in,left=.5in,right=.5in,bottom=.5in\} \}\n"
                         "\{\\ifthenelse\{ \\lengthtest\{ \\paperwidth = 297mm\}\}\n"
                         "\{\\geometry\{top=1cm,left=1cm,right=1cm,bottom=1cm\} \}\n"
                         "\{\\geometry\{top=1cm,left=1cm,right=1cm,bottom=1cm\} \}\n"
                         "\}\n"
                         "% Turn off header and footer\n"
                         "\\pagestyle\{empty\}\n"
                         "% Redefine section commands to use less space\n"
                         "\\makeatletter\n"
                         "\\renewcommand\{\\section\}\{\\@startsection\{section\}\{1\}\{0mm\}%\n"
                         "\{-1ex plus -.5ex minus -.2ex\}%\n"
                         "\{0.5ex plus .2ex\}%x\n"
                         "\{\\normalfont\\large\\bfseries\}\}\n"
                         "\\renewcommand\{\\subsection\}\{\\@startsection\{subsection\}\{2\}\{0mm\}%\n"
                         "\{-1explus -.5ex minus -.2ex\}%\n"
                         "\{0.5ex plus .2ex\}%\n"
                         "\{\\normalfont\\normalsize\\bfseries\}\}\n"
                         "\\renewcommand\{\\subsubsection\}\{\\@startsection\{subsubsection\}\{3\}\{0mm\}%\n"
                         "\{-1ex plus -.5ex minus -.2ex\}%\n"
                         "\{1ex plus .2ex\}%\n"
                         "\{\\normalfont\\small\\bfseries\}\}\n"
                         "\\makeatother\n"
                         "% Define BibTeX command\n"
                         "\\def\\BibTeX\{\{\\rm B\\kern-.05em\{\\sc i\\kern-.025em b\}\\kern-.08em\n"
                         "T\\kern-.1667em\\lower.7ex\\hbox\{E\}\\kern-.125emX\}\}\n"
                         "% Don't print section numbers\n"
                         "\\setcounter\{secnumdepth\}\{0\}\n"
                         "\\setlength\{\\parindent\}\{0pt\}\n"
                         "\\setlength\{\\parskip\}\{0pt plus 0.5ex\}\n")
                        ("\\section{%s}" . "\\section*{%s}")
                        ("\\subsection{%s}" . "\\subsection*{%s}")
                        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
       ))
  )

(defun config-org ()
  ;; (org-alert-enable)
  (setq org-log-done t)
  (setq org-latex-pdf-process (list "latexmk -f -pdf %f"))
  (setq org-directory "~/org")
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  ;; default options for all output formats
  (setq org-pandoc-options '((standalone . t)))
  ;; cancel above settings only for 'docx' format
  (setq org-pandoc-options-for-docx '((standalone . nil)))
  ;; special settings for beamer-pdf and latex-pdf exporters
  (setq org-pandoc-options-for-beamer-pdf '((pdf-engine . "xelatex")))
  (setq org-pandoc-options-for-latex-pdf '((pdf-engine . "xelatex")))

  (setq org-publish-project-alist
        '(("html"
           :base-directory "~/org/"
           :base-extension "org"
           :publishing-directory "~/org/exports"
           :publishing-function org-html-publish-to-html
           :recursive nil)
          ("books"
           :base-directory "~/org/books"
           :base-extension "org"
           :publishing-directory "~/org/exports/books"
           :publishing-function org-html-publish-to-html)
          ("wiki"
           :base-directory "~/org/wiki"
           :base-extension "org"
           :publishing-directory "~/org/exports/wiki"
           :publishing-function org-html-publish-to-html)
          ("wikipdf"
           :base-directory "~/org/wiki"
           :base-extension "org"
           :publishing-directory "~/org/exports/wiki"
           :publishing-function org-latex-publish-to-pdf)
          ("pdf"
           :base-directory "~/org/"
           :base-extension "org"
           :publishing-directory "~/org/exports"
           :publishing-function org-latex-publish-to-pdf
           :recursive nil)
          ("letters"
           :base-directory "~/org/letters"
           :base-extension "org"
           :publishing-directory "~/org/exports/letters"
           :publishing-function org-koma-letter-export-to-pdf)
          ("slides"
           :base-directory "~/org/slides"
           :base-extension "org"
           :publishing-directory "~/org/exports/slides"
           :publishing-function org-ioslide-export-as-html)
          ("all" :components ("html" "pdf"))))
  (setq org-mobile-inbox-for-pull (concat org-directory "/flagged.org"))
  (setq org-mobile-directory "~/Dropbox/MobileOrg")
  (setq org-plantuml-jar-path "~/.emacs.d/plantuml.jar")
  (setq org-ditaa-jar-path "~/.emacs.d/ditaa.jar")
  (setq org-caldav-url "https://box.jelveh.me/cloud/remote.php/caldav/calendars/reza@jelveh.me")
  (setq org-caldav-calendars
        '((:calendar-id "workkvh" :files ("~/org/work.org")
                        :inbox "~/org/fromwork.org")))
  (setq org-board-capture-file (concat org-directory "/my-org-board.org"))

  (setq org-ref-bibliography-notes "~/org/bibliography/notes.org"
        org-ref-default-bibliography '("~/org/bibliography/references.bib")
        org-ref-pdf-directory "~/Documents/References/")

  (setq org-agenda-custom-commands
        '(("x" agenda)
          ("y" agenda*)
          ("w" todo "WAITING")
          ("W" todo-tree "WAITING")
          ("s" todo "STARTED")
          ("S" todo-tree "STARTED")
          ("c" tags "+COMPUTER")
          ("t" tags "+TELEPHONE")
          ("o" . "OFFICE tag searches")
          ("os" tags "+OFFICE+ITIN")
          ("op" tags "+OFFICE+ITE")
          ("oc" tags "+OFFICE+ITA")
          ("ol" tags "+OFFICE+LUNCHTIME")
          ("ot" tags "+OFFICE+TELEPHONE")
          ("or" tags "+OFFICE+RETROSPECTIVE")
          ("od" tags "+OFFICE+DAILYSCRUM")
          ("oa" tags "+OFFICE+ASAP")
          ("h" . "HOME tag searches")
          ("hi" tags "+HOME+MA")
          ("hc" tags "+HOME+COMPUTER")
          ("hp" tags "+HOME+TELEPHONE")
          ("hr" tags "+HOME+VIKI")
          ("W" "Completed and/or deferred tasks from previous week"
           ((agenda "" ((org-agenda-span 7)
                        (org-agenda-start-day "-7d")
                        (org-agenda-entry-types '(:timestamp))
                        (org-agenda-show-log t)))))))

  (setq restclient-use-org t)
  (defvar yt-iframe-format
    (concat "<iframe width=\"440\""
            " height=\"335\""
            " src=\"https://www.youtube.com/embed/%s\""
            " frameborder=\"0\""
            " allowfullscreen>%s</iframe>"))

  (let ((org-time-stamp-custom-formats
         '("<%A, %B %d, %Y>" . "<%A, %B %d, %Y %H:%M>"))
        (org-display-custom-times 't)))
  (org-link-set-parameters
   "yt"
   :follow (lambda (handle)
     (browse-url
      (concat "https://www.youtube.com/embed/" handle)))
   :export (lambda (path desc backend)
     (cl-case backend
       (html (format yt-iframe-format
                     path (or desc "")))
       (latex (format "\href{%s}{%s}"
                      path (or desc "video"))))))
  (with-eval-after-load 'org
    ;; (use-package org-protocol)
    (add-to-list 'org-modules 'org-protocol)
    (add-to-list 'org-modules 'org-protocol-capture-html)
    (add-to-list 'org-modules 'org-web-tools)
    (setq org-confirm-babel-evaluate nil)
    ;; (use-package ox-asciidoc)
    (advice-add 'org-timer-item :around
                #'org-timer-item--mpv-insert-playback-position)
    ;; (add-hook 'org-open-at-point-functions #'mpv-seek-to-position-at-point)
    ;; active Babel languages
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((java . t)
       ;; (ipython . t)
       (python . t)
       ;; (R . t)
       ;; (hledger . t)
       (calc . t)
       (http . t)
       (dot . t)
       (haskell . t)
       (js . t)
       (latex . t)
       (ruby . t)
       ;; (sh . t)
       (emacs-lisp . t)
       (C . t)
       (plantuml . t)
       (gnuplot . t)
       (ditaa . t)
       ))
    )

  (setq org-reveal-root (concat "file:///" (expand-file-name "~/git/reveal.js")))
  (init-org-agenda)
  (init-org-export))

(defun init-local-org ()
  (add-hook 'org-mode-hook (lambda ()
                             (push '(?s . ("#+BEGIN_SRC sh" . "#+END_SRC")) evil-surround-pairs-alist)))

  ;; (setq initial-major-mode 'org-mode)
  (use-package org-alert)

  ;; convert websites to org mode
  (use-package org-eww)
  (use-package org-web-tools)
  (require 'org-web-tools)
  (require 'eww)
  (require 'org-protocol-capture-html)

  ;; (use-package org-board)

  ;; (defun do-org-board-dl-hook ()
  ;;   (when (equal (buffer-name)
  ;;                (concat "CAPTURE-" org-board-capture-file))
  ;;     (org-board-archive)))

  ;; (add-hook 'org-capture-before-finalize-hook 'do-org-board-dl-hook)
  ;; see org-ref for use of these variables
  ;; (use-package toc-org
  ;;   :config
  ;;   (progn
  ;;     (add-hook 'org-mode-hook 'toc-org-enable)
  ;;     ))
  )
(defun add-word-to-personal-dictionary ()
  (interactive)
  (let ((current-location (point))
        (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location))))

(defun init-spellcheck ()
  ;; (setq ispell-hunspell-dict-paths-alist '("c:/msys64/mingw64/share"))
  (setq ispell-program-name "hunspell"
    ispell-dictionary "de_DE")
  (setq ispell-local-dictionary-alist
    '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)
       ("de_DE" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)))
  ;; (ispell-set-spellchecker-params)

  (add-to-list 'ispell-local-dictionary-alist
    '(("english" "[[:alpha:]]" "[^[:alpha:]]" "[']" t ("-d" "en_US") nil utf-8)))
  (add-to-list 'ispell-local-dictionary-alist
    '(("german" "[[:alpha:]]" "[^[:alpha:]]" "[']" t ("-d" "de_DE") nil utf-8)))
  (setq ispell-hunspell-dictionary-alist ispell-local-dictionary-alist)
  (setq ispell-hunspell-add-multi-dic "en_US,de_DE")

  ;; (setq ispell-program-name "hunspell"          ; Use hunspell to correct mistakes
  ;; ispell-dictionary   "german") ; Default dictionary to use
  ;; (setq ispell-program-name "hunspell")
  ;; (setq ispell-dictionary "german,english")
  ;; (setq ispell-dictionary "english")
  ;; ispell-set-spellchecker-params has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  ;; (ispell-set-spellchecker-params)
  ;; (ispell-hunspell-add-multi-dic "german,english")

  (let ((langs '("english" "german")))
    (setq lang-ring (make-ring (length langs)))
    (dolist (elem langs) (ring-insert lang-ring elem)))

  (defun cycle-ispell-languages ()
    (interactive)
    (let ((lang (ring-ref lang-ring -1)))
      (ring-insert lang-ring lang)
      (ispell-change-dictionary lang)))

  (global-set-key [f7] 'cycle-ispell-languages)
  )

;; Constants I use to refer to my system
(defconst tbh-hostname
  (car (split-string system-name "\\." t))
  "The hostname for the current system.")

(defconst tbh-home-dir
  (getenv "HOME")
  "The full path of the user's home directory.")

(defconst tbh-emacs-d-dir
  (expand-file-name ".emacs.d/" tbh-home-dir)
  "Top level directory for local configuration and code.")

(defconst tbh-spacemacs-d-dir
  (expand-file-name ".spacemacs.d/" tbh-home-dir)
  "Top level directory for local Spacemacs configuration and code.")

(defconst tbh-private-spacemacs-layers-dir
  (expand-file-name "layers/" tbh-spacemacs-d-dir)
  "Directory for storying private Spacemacs layers.")

;; (defun modi/package-dependency-check-ignore (orig-ret)
;;   "Remove the `black listed packages' from ORIG-RET."
;;   (let ((pkg-black-list '(org))
;;         new-ret
;;         pkg-name)
;;     (dolist (pkg-struct orig-ret)
;;       (setq pkg-name (package-desc-name pkg-struct))
;;       (if (member pkg-name pkg-black-list)
;;           (message (concat "Package `%s' will not be auto-installed. "
;;                            "See `modi/package-dependency-check-ignore'.")
;;                    pkg-name)
;;         ;; (message "Package to be installed: %s" pkg-name)
;;         (push pkg-struct new-ret)))
;;     new-ret))
;; (advice-add 'package-compute-transaction :filter-return #'modi/package-dependency-check-ignore)

;; Load system specific config, if it exists
(let ((tbh-system-specific-config
       (expand-file-name
        (concat tbh-hostname ".el") tbh-spacemacs-d-dir)))
  (if (file-readable-p tbh-system-specific-config)
      (load-file tbh-system-specific-config)))

;; Set up appropriate function advice
(defmacro tbh/wrap-func (func)
  (let ((advice-name (intern (format "%s--advice" func)))
        (target-name (intern (format "tbh/%s" func))))
    `(progn
       (defun ,advice-name (&rest args)
         (when (fboundp ',target-name)
           (apply ',target-name args)))
       (advice-add ',func :after ',advice-name))))

(tbh/wrap-func dotspacemacs/layers)
(tbh/wrap-func dotspacemacs/init)
(tbh/wrap-func dotspacemacs/user-init)
(tbh/wrap-func dotspacemacs/user-config)

;; Generally Useful Functions
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(defun unfill-region ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))

(defun dotspacemacs/layers ()
  "Layer configuration:
This function should only modify configuration layer settings."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs

   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused

   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t

   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press `SPC f e R' (Vim style) or
     ;; `M-m f e R' (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     ;; auto-completion
     better-defaults
     emacs-lisp
     hackernews
     epub
     (languagetool :variables
                   langtool-java-classpath "/usr/share/languagetool:/usr/share/java/languagetool/*")
     (elfeed :variables rmh-elfeed-org-files (list "~/.spacemacs.d/elfeed.org"))
     ;; helm
     lsp
     ;; markdown
     multiple-cursors
     (org :variables
          org-enable-github-support t
          org-enable-bootstrap-support t
          org-enable-reveal-js-support t
          org-enable-hugo-support t
          org-enable-roam-ui t
          org-want-todo-bindings t
          org-enable-roam-support t
          org-projectile-file "TODO.org"
          org-enable-roam-protocol t
          org-enable-sticky-header t
          org-enable-org-journal-support t
          org-journal-dir "~/org/journal/"
          org-journal-file-format "%Y-%m-%d.org"
          org-journal-date-prefix "#+TITLE: "
          org-journal-date-format "%A, %B %d %Y"
          org-journal-time-prefix "* "
          org-journal-time-format "")
     (shell :variables
            shell-default-height 30
            shell-enable-smart-eshell t
            shell-default-position 'bottom
            shell-protect-eshell-prompt t
            shell-default-shell 'ansi-term
            shell-pop-autocd-to-working-dir nil
            shell-default-term-shell "zsh")
     eaf
     rust
     php
      windows-scripts
      nginx
      spacemacs-org
      ;; confluence
      (lua :variables
        lua-backend 'lsp
        lua-lsp-server 'emmy)
      ;; ivy
      compleseus
      ess
      csv
      asciidoc
      django
      deft
      (python :variables
        python-formatter 'black
        python-format-on-save t
        python-backend 'lsp
        ;; (company-anaconda :toggle (configuration-layer/package-used-p 'company))
        python-sort-imports-on-save t)
      ipython-notebook
      (c-c++ :variables
        c-c++-enable-clang-support t
        c-c++-default-mode-for-headers
        'c++-mode)
      (auto-completion :variables
        auto-completion-return-key-behavior 'complete
        auto-completion-tab-key-behavior 'cycle
        auto-completion-complete-with-key-sequence nil
        auto-completion-complete-with-key-sequence-delay 0.1
        auto-completion-idle-delay 0.2
        auto-completion-private-snippets-directory nil
        auto-completion-enable-snippets-in-popup nil
        auto-completion-enable-help-tooltip nil
        auto-completion-use-company-box nil)
      haskell
      chinese
      kubernetes
      ;; japanese
      javascript
      json
      web-beautify
      react
      typescript
      html
      vimscript
      (terraform :variables terraform-auto-format-on-save t)
      (git :variables
        git-magit-status-fullscreen nil
        git-enable-github-support t)
      ;; git-gutter-use-fringe t)
      (go :variables go-use-gometalinter t
        gofmt-command "goimports"
        go-use-gocheck-for-testing t
        go-tab-width 4)
      protobuf
      sql
      (markdown :variables markdown-live-preview-engine 'vmd)
      xkcd
      (ruby :variables ruby-test-runner 'rspec)
      pdf
      csharp
      java
      pandoc
      plantuml
      evil-commentary
      ;; evil-cleverparens
      evil-snipe
      docker
      ;; unimpaired
      ;; vim-powerline
      finance
      ;; nlinum
      fasd
      ;; (ranger :variables
      ;;   ranger-override-dired t
      ;;   ranger-show-preview t
      ;;   ranger-cleanup-eagerly t)
      ;; wakatime
      ;; semantic
      chinese
      ruby-on-rails
      shell-scripts
      yaml
      vinegar
      systemd
      restclient
      ;; ;; tmux
      dash
      ansible
      ;; gtags
      ;; (latex :variables
      ;;   latex-build-command "LatexMk"
      ;;   latex-enable-folding t)
      ;; bibtex
      ;; ;; osx
      ;; octave
      ;; d12frosted-org
      ;; d12frosted-csharp
      ;; elixir
      speed-reading
      (spell-checking :variables
        enable-flyspell-auto-completion t
        spell-checking-enable-by-default nil)
      (version-control :variables
        version-control-diff-tool 'diff-hl
        version-control-diff-side 'left
        version-control-global-margin 't)
      fishman
      ;; common-lisp
      ;; syntax-checking
      ;; search-engine
      ;; deft
      treemacs)

   ;; List of additional packages that will be installed without being wrapped
   ;; in a layer (generally the packages are installed only and should still be
   ;; loaded using load/require/use-package in the user-config section below in
   ;; this file). If you need some configuration for these packages, then
   ;; consider creating a layer. You can also put the configuration in
   ;; `dotspacemacs/user-config'. To use a local version of a package, use the
   ;; `:location' property: '(your-package :location "~/path/to/your-package/")
   ;; Also include the dependencies as they will not be resolved automatically.
   dotspacemacs-additional-packages '(evil-replace-with-register
                                      counsel-org-clock
                                      angular-mode
                                      angular-snippets
                                      ;; hledger-mode
                                      ;; (org-glossary :location (recipe :fetcher github :repo "jagrg/org-glossary"))
                                      (toc-org :location (recipe :fetcher github :repo "snosov1/toc-org"))
                                      (org-protocol-capture-html :location (recipe :fetcher github :repo "alphapapa/org-protocol-capture-html"))
                                      org-caldav
                                      ;; org-board
                                      (org-web-tools :location (recipe :fetcher github :repo "alphapapa/org-web-tools"))
                                      ;; org-web-tools
                                      ;; (org-web-tools :location (recipe :fetcher github :repo alphapapa/org-web-tools))
                                      password-generator
                                      bbdb
                                      tldr
                                      ;; (org-wiki :location (recipe :fetcher github :repo "fishman/org-wiki" :branch "helm_to_consul"))
                                      focus
                                      ivy-youtube
                                      ;; ob-ipython
                                      org-drill-table
                                      kaolin-themes
                                      gruvbox-theme
                                      simple-mpc
                                      (ox-asciidoc :location (recipe :fetcher github :repo "alphapapa/org-web-tools"))
                                      (ox-ioslide :location (recipe :fetcher github :repo "fishman/org-ioslide"))
                                      w3m xwidgete spray org-alert nxml xml-rpc langtool)

    ;; A list of packages that cannot be updated.
    dotspacemacs-frozen-packages '()

    ;; A list of packages that will not be installed and loaded.
    dotspacemacs-excluded-packages '()

    ;; Defines the behaviour of Spacemacs when installing packages.
    ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
    ;; `used-only' installs only explicitly used packages and deletes any unused
    ;; packages as well as their unused dependencies. `used-but-keep-unused'
    ;; installs only the used packages but won't delete unused ones. `all'
    ;; installs *all* packages supported by Spacemacs and never uninstalls them.
    ;; (default is `used-only')
    dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization:
This function is called at the very beginning of Spacemacs startup,
before layer configuration.
It should only modify the values of Spacemacs settings."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non-nil then enable support for the portable dumper. You'll need to
   ;; compile Emacs 27 from source following the instructions in file
   ;; EXPERIMENTAL.org at to root of the git repository.
   ;;
   ;; WARNING: pdumper does not work with Native Compilation, so it's disabled
   ;; regardless of the following setting when native compilation is in effect.
   ;;
   ;; (default nil)
   dotspacemacs-enable-emacs-pdumper nil

   ;; Name of executable file pointing to emacs 27+. This executable must be
   ;; in your PATH.
   ;; (default "emacs")
   dotspacemacs-emacs-pdumper-executable-file "emacs"

   ;; Name of the Spacemacs dump file. This is the file will be created by the
   ;; portable dumper in the cache directory under dumps sub-directory.
   ;; To load it when starting Emacs add the parameter `--dump-file'
   ;; when invoking Emacs 27.1 executable on the command line, for instance:
   ;;   ./emacs --dump-file=$HOME/.emacs.d/.cache/dumps/spacemacs-27.1.pdmp
   ;; (default (format "spacemacs-%s.pdmp" emacs-version))
   dotspacemacs-emacs-dumper-dump-file (format "spacemacs-%s.pdmp" emacs-version)

   ;; If non-nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t

   ;; Maximum allowed time in seconds to contact an ELPA repository.
   ;; (default 5)
   dotspacemacs-elpa-timeout 5

   ;; Set `gc-cons-threshold' and `gc-cons-percentage' when startup finishes.
   ;; This is an advanced option and should not be changed unless you suspect
   ;; performance issues due to garbage collection operations.
   ;; (default '(100000000 0.1))
   dotspacemacs-gc-cons '(100000000 0.1)

   ;; Set `read-process-output-max' when startup finishes.
   ;; This defines how much data is read from a foreign process.
   ;; Setting this >= 1 MB should increase performance for lsp servers
   ;; in emacs 27.
   ;; (default (* 1024 1024))
   dotspacemacs-read-process-output-max (* 1024 1024)

   ;; If non-nil then Spacelpa repository is the primary source to install
   ;; a locked version of packages. If nil then Spacemacs will install the
   ;; latest version of packages from MELPA. Spacelpa is currently in
   ;; experimental state please use only for testing purposes.
   ;; (default nil)
   dotspacemacs-use-spacelpa nil

   ;; If non-nil then verify the signature for downloaded Spacelpa archives.
   ;; (default t)
   dotspacemacs-verify-spacelpa-archives t

   ;; If non-nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil

   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'. (default 'emacs-version)
   dotspacemacs-elpa-subdirectory 'emacs-version

   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim

   ;; If non-nil show the version string in the Spacemacs buffer. It will
   ;; appear as (spacemacs version)@(emacs version)
   ;; (default t)
   dotspacemacs-startup-buffer-show-version t

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official

   ;; Scale factor controls the scaling (size) of the startup banner. Default
   ;; value is `auto' for scaling the logo automatically to fit all buffer
   ;; contents, to a maximum of the full image height and a minimum of 3 line
   ;; heights. If set to a number (int or float) it is used as a constant
   ;; scaling factor for the default logo size.
   dotspacemacs-startup-banner-scale 'auto

   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `recents-by-project' `bookmarks' `projects' `agenda' `todos'.
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   ;; The exceptional case is `recents-by-project', where list-type must be a
   ;; pair of numbers, e.g. `(recents-by-project . (7 .  5))', where the first
   ;; number is the project limit and the second the limit on the recent files
   ;; within a project.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7)
                                (agenda . 2))
   ;; True if the home buffer should respond to resize events. (default t)
   dotspacemacs-startup-buffer-responsive t

   ;; Show numbers before the startup list lines. (default t)
   dotspacemacs-show-startup-list-numbers t

   ;; The minimum delay in seconds between number key presses. (default 0.4)
   dotspacemacs-startup-buffer-multi-digit-delay 0.4

   ;; If non-nil, show file icons for entries and headings on Spacemacs home buffer.
   ;; This has no effect in terminal or if "all-the-icons" package or the font
   ;; is not installed. (default nil)
   dotspacemacs-startup-buffer-show-icons nil

   ;; Default major mode for a new empty buffer. Possible values are mode
   ;; names such as `text-mode'; and `nil' to use Fundamental mode.
   ;; (default `text-mode')
   dotspacemacs-new-empty-buffer-major-mode 'text-mode

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode

   ;; If non-nil, *scratch* buffer will be persistent. Things you write down in
   ;; *scratch* buffer will be saved and restored automatically.
   dotspacemacs-scratch-buffer-persistent nil

   ;; If non-nil, `kill-buffer' on *scratch* buffer
   ;; will bury it instead of killing.
   dotspacemacs-scratch-buffer-unkillable nil

   ;; Initial message in the scratch buffer, such as "Welcome to Spacemacs!"
   ;; (default nil)
   dotspacemacs-initial-scratch-message nil

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press `SPC T n' to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light
                          ;; (kaolin-dark :location (recipe :fetcher github
                          ;;                          :repo "ogdenwebb/emacs-kaolin-themes"))

                          atom-one-dark
                          monokai
                          gruvbox-dark-hard
                          wombat
                          darktooth
                          smyx
                          zenburn
                          base16-monokai
                          misterioso
                          solarized-light
                          solarized-dark
                          leuven
                          )
   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `doom', `vim-powerline' and `vanilla'. The
   ;; first three are spaceline themes. `doom' is the doom-emacs mode-line.
   ;; `vanilla' is default Emacs mode-line. `custom' is a user defined themes,
   ;; refer to the DOCUMENTATION.org for more info on how to create your own
   ;; spaceline theme. Value can be a symbol or list with additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   dotspacemacs-mode-line-theme '(spacemacs :separator wave :separator-scale 1.5)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font or prioritized list of fonts. The `:size' can be specified as
   ;; a non-negative integer (pixel size), or a floating-point (point size).
   ;; Point size is recommended, because it's device independent. (default 10.0)
   dotspacemacs-default-font '("Hack Nerd Font"
                               :size 18
                               ;; :powerline-scale 1.1)
                               :weight normal
                               :width normal)

   ;; The leader key (default "SPC")
   dotspacemacs-leader-key "SPC"

   ;; The key used for Emacs commands `M-x' (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"

   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"

   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"

   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","

   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m" for terminal mode, "<M-return>" for GUI mode).
   ;; Thus M-RET should work as leader key in both GUI and terminal modes.
   ;; C-M-m also should work in terminal mode, but not in GUI mode.
   dotspacemacs-major-mode-emacs-leader-key (if window-system "<M-return>" "C-M-m")

   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs `C-i', `TAB' and `C-m', `RET'.
   ;; Setting it to a non-nil value, allows for separate commands under `C-i'
   ;; and TAB or `C-m' and `RET'.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil

   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"

   ;; If non-nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil

   ;; If non-nil then the last auto saved layouts are resumed automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil

   ;; If non-nil, auto-generate layout name when creating new layouts. Only has
   ;; effect when using the "jump to layout by number" commands. (default nil)
   dotspacemacs-auto-generate-layout-names nil

   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1

   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache

   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5

   ;; If non-nil, the paste transient-state is enabled. While enabled, after you
   ;; paste something, pressing `C-j' and `C-k' several times cycles through the
   ;; elements in the `kill-ring'. (default nil)
   dotspacemacs-enable-paste-transient-state nil

   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4

   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom

   ;; Control where `switch-to-buffer' displays the buffer. If nil,
   ;; `switch-to-buffer' displays the buffer in the current window even if
   ;; another same-purpose window is available. If non-nil, `switch-to-buffer'
   ;; displays the buffer in a same-purpose window even if the buffer can be
   ;; displayed in the current window. (default nil)
   dotspacemacs-switch-to-buffer-prefers-purpose nil

   ;; If non-nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t

   ;; If non-nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil

   ;; If non-nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non-nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil

   ;; If non-nil the frame is undecorated when Emacs starts up. Combine this
   ;; variable with `dotspacemacs-maximized-at-startup' in OSX to obtain
   ;; borderless fullscreen. (default nil)
   dotspacemacs-undecorated-at-startup nil

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90

   ;; If non-nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t

   ;; If non-nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t

   ;; If non-nil unicode symbols are displayed in the mode line.
   ;; If you use Emacs as a daemon and wants unicode characters only in GUI set
   ;; the value to quoted `display-graphic-p'. (default t)
   dotspacemacs-mode-line-unicode-symbols t

   ;; If non-nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t

   ;; Show the scroll bar while scrolling. The auto hide time can be configured
   ;; by setting this variable to a number. (default t)
   dotspacemacs-scroll-bar-while-scrolling t

   ;; Control line numbers activation.
   ;; If set to `t', `relative' or `visual' then line numbers are enabled in all
   ;; `prog-mode' and `text-mode' derivatives. If set to `relative', line
   ;; numbers are relative. If set to `visual', line numbers are also relative,
   ;; but only visual lines are counted. For example, folded lines will not be
   ;; counted and wrapped lines are counted as multiple lines.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :visual nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; When used in a plist, `visual' takes precedence over `relative'.
   ;; (default nil)
   dotspacemacs-line-numbers '(:relative t
                                :visual nil
                                :disabled-for-modes dired-mode
                                doc-view-mode
                                markdown-mode
                                org-mode
                                pdf-view-mode
                                text-mode
                                :size-limit-kb 1000)
    ;; dotspacemacs-line-numbers nil

   ;; Code folding method. Possible values are `evil', `origami' and `vimish'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil

   ;; If non-nil and `dotspacemacs-activate-smartparens-mode' is also non-nil,
   ;; `smartparens-strict-mode' will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil

   ;; If non-nil smartparens-mode will be enabled in programming modes.
   ;; (default t)
   dotspacemacs-activate-smartparens-mode t

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc...
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil

   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all

   ;; If non-nil, start an Emacs server if one is not already running.
   ;; (default nil)
   dotspacemacs-enable-server t

   ;; Set the emacs server socket location.
   ;; If nil, uses whatever the Emacs default is, otherwise a directory path
   ;; like \"~/.emacs.d/server\". It has no effect if
   ;; `dotspacemacs-enable-server' is nil.
   ;; (default nil)
   dotspacemacs-server-socket-dir nil

   ;; If non-nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil

   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `rg', `ag', `pt', `ack' and `grep'.
   ;; (default '("rg" "ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")

   ;; Format specification for setting the frame title.
   ;; %a - the `abbreviated-file-name', or `buffer-name'
   ;; %t - `projectile-project-name'
   ;; %I - `invocation-name'
   ;; %S - `system-name'
   ;; %U - contents of $USER
   ;; %b - buffer name
   ;; %f - visited file name
   ;; %F - frame name
   ;; %s - process status
   ;; %p - percent of buffer above top of window, or Top, Bot or All
   ;; %P - percent of buffer above bottom of window, perhaps plus Top, or Bot or All
   ;; %m - mode name
   ;; %n - Narrow if appropriate
   ;; %z - mnemonics of buffer, terminal, and keyboard coding systems
   ;; %Z - like %z, but including the end-of-line format
   ;; If nil then Spacemacs uses default `frame-title-format' to avoid
   ;; performance issues, instead of calculating the frame title by
   ;; `spacemacs/title-prepare' all the time.
   ;; (default "%I@%S")
   dotspacemacs-frame-title-format "%I@%S"

   ;; Format specification for setting the icon title format
   ;; (default nil - same as frame-title-format)
   dotspacemacs-icon-title-format nil

   ;; Color highlight trailing whitespace in all prog-mode and text-mode derived
   ;; modes such as c++-mode, python-mode, emacs-lisp, html-mode, rst-mode etc.
   ;; (default t)
   dotspacemacs-show-trailing-whitespace t

   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil

   ;; If non-nil activate `clean-aindent-mode' which tries to correct
   ;; virtual indentation of simple modes. This can interfere with mode specific
   ;; indent handling like has been reported for `go-mode'.
   ;; If it does deactivate it here.
   ;; (default t)
   dotspacemacs-use-clean-aindent-mode t

   ;; Accept SPC as y for prompts if non-nil. (default nil)
   dotspacemacs-use-SPC-as-y nil

   ;; If non-nil shift your number row to match the entered keyboard layout
   ;; (only in insert state). Currently supported keyboard layouts are:
   ;; `qwerty-us', `qwertz-de' and `querty-ca-fr'.
   ;; New layouts can be added in `spacemacs-editing' layer.
   ;; (default nil)
   dotspacemacs-swap-number-row nil

   ;; Either nil or a number of seconds. If non-nil zone out after the specified
   ;; number of seconds. (default nil)
   dotspacemacs-zone-out-when-idle nil

   ;; Run `spacemacs/prettify-org-buffer' when
   ;; visiting README.org files of Spacemacs.
   ;; (default nil)
   dotspacemacs-pretty-docs nil

;; If nil the home buffer shows the full path of agenda items
;; and todos. If non nil only the file name is shown.
dotspacemacs-home-shorten-agenda-source nil

;; If non-nil then byte-compile some of Spacemacs files.
dotspacemacs-byte-compile nil))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session. By
default it calls `spacemacs/load-spacemacs-env' which loads the environment
variables declared in `~/.spacemacs.env' or `~/.spacemacs.d/.spacemacs.env'.
See the header of this file for more information."
  (spacemacs/load-spacemacs-env)
  )

(defun my-open-link-function ()
  "Open link, interpreting it a the name of a headline."
  (let* ((el (org-element-context))
         (type (first el))
         (link-type (plist-get (cadr el) :type))
         (path (let ((path-1 (plist-get (cadr el) :path)))
                 (when (stringp path-1)
                   (org-link-unescape path-1)))))
    (when (and (eql type 'link)
               path
               (string= link-type "fuzzy"))
      (let* ((path (regexp-quote path))
             (result
              (delq nil
                    (org-map-entries
                     (lambda ()
                       (when (string-match
                              path
                              (org-get-heading))
                         (list (buffer-file-name) (point))))
                     nil
                     ;; Here we set the scope.
                     ;; 'agenda would search in all agenda files.
                     ;; We want a list of all org files in `my-link-search-directory'.
                     (directory-files
                      my-link-search-directory
                      t "[.]org\\'")))))
        (when result
          (when (> (length result) 1)
            (message "Warning: multiple search results for %s" path))
          (let ((file (caar result))
                (pos (cadar result)))
            (find-file file)
            (goto-char pos)))))))

;; git
;; (git :variables
;;      git-magit-status-fullscreen t
;;      git-enable-github-support t
;;      git-gutter-use-fringe t)
(defun increment-number-at-point ()
  (interactive)
  (skip-chars-backward "0-9")
  (or (looking-at "[0-9]+")
    (error "No number at point"))
  (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))



(defun evil-init ()
  (defun kbd+ (keyrep &optional need-vector)
    (if (vectorp keyrep) keyrep (edmacro-parse-keys keyrep need-vector)))

  (defun gmap (keyrep defstr)
    "Vim-style global keybinding. Uses the `global-set-key' binding function."
    (global-set-key (kbd+ keyrep) (edmacro-parse-keys defstr t)))

  (defun fmap (keybind-fn keyrep defstr)
    "Vim-style keybinding using the key binding function KEYBIND-FN."
    (call keybind-fn (kbd+ keyrep) (edmacro-parse-keys defstr t)))

  (defun xmap (keymap keyrep defstr)
    "Vim-style keybinding in KEYMAP. Uses the `define-key' binding function."
    (define-key keymap (kbd+ keyrep) (edmacro-parse-keys defstr t)))

  (defun nmap (keyrep defstr) "Vim-style keybinding for `evil-normal-state.' Uses the `define-key' binding function."
    (xmap evil-normal-state-map keyrep defstr))
  (defun imap (keyrep defstr) "Vim-style keybinding for `evil-insert-state'. Uses the `define-key' binding function."
    (xmap evil-insert-state-map keyrep defstr))
  (defun vmap (keyrep defstr) "Vim-style keybinding for `evil-visual-state'. Uses the `define-key' binding function."
    (xmap evil-visual-state-map keyrep defstr))
  (defun mmap (keyrep defstr) "Vim-style keybinding for `evil-motion-state'. Uses the `define-key' binding function."
    (xmap evil-motion-state-map keyrep defstr))

  (nmap "X" "ci\"")
  )

(defun term-init ()
  ;; http://www.reddit.com/r/emacs/comments/123lbu/there_must_be_a_better_way_to_switch_between/c6rzl48
  ;; As of this writing, emacs does not correctly recognize some xterm
  ;; key sequences.  Add code to deal with these.
  (defun add-escape-key-mapping-alist (escape-prefix key-prefix
                                        suffix-alist)
    "Add mappings for up, down, left and right keys for a given list
 of escape sequences and list of keys."
    (while suffix-alist
      (let ((escape-suffix (car (car suffix-alist)))
             (key-suffix (cdr (car suffix-alist))))
        (define-key input-decode-map (concat escape-prefix escape-suffix)
          (read-kbd-macro (concat key-prefix key-suffix))))
      (setq suffix-alist (cdr suffix-alist))))

  (setq nav-key-pair-alist
    '(("A" . "<up>") ("B" . "<down>") ("C" . "<right>") ("D" . "<left>")
       ("H" . "<home>") ("F" . "<end>") ("I" . "<tab>") ("s" . "\"")
       ("l" . ",") ("n" . ";") ("^" . "<return>")))

  (add-escape-key-mapping-alist "\e[1;2" "S-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;3" "M-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;4" "M-S-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;5" "C-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;6" "C-S-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;7" "M-C-" nav-key-pair-alist)
  (add-escape-key-mapping-alist "\e[1;8" "M-C-S-" nav-key-pair-alist)

  ;; (add-hook 'term-setup-hook
  ;;   '(lambda ()
  ;;      (if (getenv "TMUX")
  ;;        (define-key input-decode-map "\e[1;3A" [M-up])
  ;;        (define-key input-decode-map "\e[1;3B" [M-down])
  ;;        (define-key input-decode-map "\e[1;3C" [M-right])
  ;;        (define-key input-decode-map "\e[1;3D" [M-left])
  ;;        (define-key input-decode-map "\e[1;2A" [S-up])
  ;;        (define-key input-decode-map "\e[1;2B" [S-down])
  ;;        (define-key input-decode-map "\e[1;2C" [S-right])
  ;;        (define-key input-decode-map "\e[1;2D" [S-left])
  ;;        (define-key input-decode-map "\e[1;4A" [M-S-up])
  ;;        (define-key input-decode-map "\e[1;4B" [M-S-down])
  ;;        (define-key input-decode-map "\e[1;4C" [M-S-right])
  ;;        (define-key input-decode-map "\e[1;4D" [M-S-left])
  ;;        (define-key input-decode-map "\e[1;7A" [C-M-up])
  ;;        (define-key input-decode-map "\e[1;7B" [C-M-down])
  ;;        (define-key input-decode-map "\e[1;7C" [C-M-S-right])
  ;;        (define-key input-decode-map "\e[1;7D" [C-M-left])

  ;;        (progn
  ;;          (let ((x 2) (tkey ""))
  ;;            (while (<= x 8)
  ;;              ;; shift
  ;;              (if (= x 2)
  ;;                (setq tkey "s-"))
  ;;              ;; alt
  ;;              (if (= x 3)
  ;;                (setq tkey "m-"))
  ;;              ;; alt + shift
  ;;              (if (= x 4)
  ;;                (setq tkey "m-s-"))
  ;;              ;; ctrl
  ;;              (if (= x 5)
  ;;                (setq tkey "c-"))
  ;;              ;; ctrl + shift
  ;;              (if (= x 6)
  ;;                (setq tkey "c-s-"))
  ;;              ;; ctrl + alt
  ;;              (if (= x 7)
  ;;                (setq tkey "c-m-"))
  ;;              ;; ctrl + alt + shift
  ;;              (if (= x 8)
  ;;                (setq tkey "c-m-s-"))

  ;;              ;; arrows
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d a" x)) (kbd (format "%s<up>" tkey)))
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d b" x)) (kbd (format "%s<down>" tkey)))
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d c" x)) (kbd (format "%s<right>" tkey)))
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d d" x)) (kbd (format "%s<left>" tkey)))
  ;;              ;; home
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d h" x)) (kbd (format "%s<home>" tkey)))
  ;;              ;; end
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d f" x)) (kbd (format "%s<end>" tkey)))
  ;;              ;; page up
  ;;              (define-key key-translation-map (kbd (format "m-[ 5 ; %d ~" x)) (kbd (format "%s<prior>" tkey)))
  ;;              ;; page down
  ;;              (define-key key-translation-map (kbd (format "m-[ 6 ; %d ~" x)) (kbd (format "%s<next>" tkey)))
  ;;              ;; insert
  ;;              (define-key key-translation-map (kbd (format "m-[ 2 ; %d ~" x)) (kbd (format "%s<delete>" tkey)))
  ;;              ;; delete
  ;;              (define-key key-translation-map (kbd (format "m-[ 3 ; %d ~" x)) (kbd (format "%s<delete>" tkey)))
  ;;              ;; f1
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d p" x)) (kbd (format "%s<f1>" tkey)))
  ;;              ;; f2
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d q" x)) (kbd (format "%s<f2>" tkey)))
  ;;              ;; f3
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d r" x)) (kbd (format "%s<f3>" tkey)))
  ;;              ;; f4
  ;;              (define-key key-translation-map (kbd (format "m-[ 1 ; %d s" x)) (kbd (format "%s<f4>" tkey)))
  ;;              ;; f5
  ;;              (define-key key-translation-map (kbd (format "m-[ 15 ; %d ~" x)) (kbd (format "%s<f5>" tkey)))
  ;;              ;; f6
  ;;              (define-key key-translation-map (kbd (format "m-[ 17 ; %d ~" x)) (kbd (format "%s<f6>" tkey)))
  ;;              ;; f7
  ;;              (define-key key-translation-map (kbd (format "m-[ 18 ; %d ~" x)) (kbd (format "%s<f7>" tkey)))
  ;;              ;; f8
  ;;              (define-key key-translation-map (kbd (format "m-[ 19 ; %d ~" x)) (kbd (format "%s<f8>" tkey)))
  ;;              ;; f9
  ;;              (define-key key-translation-map (kbd (format "m-[ 20 ; %d ~" x)) (kbd (format "%s<f9>" tkey)))
  ;;              ;; f10
  ;;              (define-key key-translation-map (kbd (format "m-[ 21 ; %d ~" x)) (kbd (format "%s<f10>" tkey)))
  ;;              ;; f11
  ;;              (define-key key-translation-map (kbd (format "m-[ 23 ; %d ~" x)) (kbd (format "%s<f11>" tkey)))
  ;;              ;; f12
  ;;              (define-key key-translation-map (kbd (format "m-[ 24 ; %d ~" x)) (kbd (format "%s<f12>" tkey)))
  ;;              ;; f13
  ;;              (define-key key-translation-map (kbd (format "m-[ 25 ; %d ~" x)) (kbd (format "%s<f13>" tkey)))
  ;;              ;; f14
  ;;              (define-key key-translation-map (kbd (format "m-[ 26 ; %d ~" x)) (kbd (format "%s<f14>" tkey)))
  ;;              ;; f15
  ;;              (define-key key-translation-map (kbd (format "m-[ 28 ; %d ~" x)) (kbd (format "%s<f15>" tkey)))
  ;;              ;; f16
  ;;              (define-key key-translation-map (kbd (format "m-[ 29 ; %d ~" x)) (kbd (format "%s<f16>" tkey)))
  ;;              ;; f17
  ;;              (define-key key-translation-map (kbd (format "m-[ 31 ; %d ~" x)) (kbd (format "%s<f17>" tkey)))
  ;;              ;; f18
  ;;              (define-key key-translation-map (kbd (format "m-[ 32 ; %d ~" x)) (kbd (format "%s<f18>" tkey)))
  ;;              ;; f19
  ;;              (define-key key-translation-map (kbd (format "m-[ 33 ; %d ~" x)) (kbd (format "%s<f19>" tkey)))
  ;;              ;; f20
  ;;              (define-key key-translation-map (kbd (format "m-[ 34 ; %d ~" x)) (kbd (format "%s<f20>" tkey)))

  ;;              (setq x (+ x 1))
  ;;              ))
  ;;          )
  ;;        )
  ;;      ))
  )

(defun dotspacemacs/user-init ()
  "Initialization for user code:
This function is called immediately after `dotspacemacs/init', before layer
configuration.
It is mostly for variables that should be set before packages are loaded.
If you are unsure, try setting them in `dotspacemacs/user-config' first."
  ;; (setq configuration-layer--elpa-archives
  ;;       '(("melpa"    . "melpa.org/packages/")
  ;;         ("org"      . "orgmode.org/elpa/")
  ;; ("gnu"      . "elpa.gnu.org/packages/"))

  ;; (golden-ratio-mode 1)
  ;; (setq evil-want-fine-undo 't)
  ;;  (spacemacs/load-or-install-package 'sx t)
  ;;  (require 'sx-load)
  ;; (setq org-bullets-bullet-list '("■" "◆" "▲" "▶"))

  ;; (add-hook 'c-mode-hook 'ycmd-mode))
  (defun dired-open-file ()
    "in dired, open the file named on this line."
    (interactive)
    (let* ((file (dired-get-filename nil t)))
      (message "opening %s..." file)
      (call-process "xdg-open" nil 0 nil file)
      (message "opening %s done" file)))
  ;; (server-start)
  ;; (init-local-org)
  (init-spellcheck)
  ;; font
  ;; (set-face-attribute 'default nil :family "mononoki")
  ;; (set-face-attribute 'default nil :family "nanumgothiccoding")
  ;; (set-face-attribute 'default nil :family "Saucei' CODE powerline")
  ;; (set-face-attribute 'default nil :family "SauceCodePro NerdFont Mono Regular")
  ;; (set-face-attribute 'default nil :height 140)
  ;; (set-face-attribute 'default nil :weight 'normal)
  )


(defun dotspacemacs/user-load ()
  "Library to load while dumping.
This function is called only while dumping Spacemacs configuration. You can
`require' or `load' the libraries of your choice that will be included in the
dump."
)

(defun dotspacemacs/user-config ()
  ;; (setq org-download-screenshot-method "flameshot")
  (setq org-download-screenshot-method "flameshot gui --raw > %s")
  (setq spaceline-org-clock-p t)
  (setq org-roam-directory (file-truename "~/org/roam")) 
  (global-set-key (kbd "C-a") 'increment-number-at-point)

  (add-hook 'doc-view-mode-hook 'auto-revert-mode)

  (custom-set-faces
    '(ein:cell-input-area ((t (:background "#646464"))))
     '(ein:cell-input-prompt ((t (:inherit header-line :background "#484848" :foreground "dimgray" :height 0.8)))))
  ;; Set the Emacs customization file path. Must be done here in user-init.
  (setq custom-file "~/.spacemacs.d/spacemacscustom.el")
  ;; (setq org-src-tab-acts-natively t)
  ;; Required to use hledger instead of ledger itself.
  (defun copy-to-clipboard ()
    "Copies selection to x-clipboard."
    (interactive)
    (if (display-graphic-p)
      (progn
        (message "Yanked region to x-clipboard!")
        (call-interactively 'clipboard-kill-ring-save)
        )
      (if (region-active-p)
        (progn
          (shell-command-on-region (region-beginning) (region-end) "xsel -i -b")
          (message "Yanked region to clipboard!")
          (deactivate-mark))
        (message "No region active; can't yank to clipboard!")))
    )

  (defun paste-from-clipboard ()
    "Pastes from x-clipboard."
    (interactive)
    (if (display-graphic-p)
      (progn
        (clipboard-yank)
        (message "graphics active")
        )
      (insert (shell-command-to-string "xsel -o -b"))
      )
    )
  (evil-leader/set-key "o y" 'copy-to-clipboard)
  (evil-leader/set-key "o p" 'paste-from-clipboard)

  (setq evil-search-module 'isearch)
  (setq ledger-mode-should-check-version nil
    ledger-report-links-in-register nil
    ledger-binary-path "hledger")
  (config-org)
  (init-org-templates)
  "Configuration function.
   This function is called at the very end of Spacemacs initialization after
   layers configuration."
  (setq dotspacemacs-version-check-enable 'nil)
  (setq nlinum-relative-redisplay-delay 0.1)
  (add-to-list 'exec-path "~/bin")
  ;; allow spacemacs to be used as GIT_EDITOR
  ;; (global-git-commit-mode t)
  ;; (setq langtool-language-tool-jar "/usr/share/java/languagetool/languagetool.jar")

  (setq magit-repository-directories '("~/git"))
  (setq-default ycmd-server-command '("python" "~/.vim/pack/default/YouCompleteMe/third_party/ycmd/ycmd"))
  (setq-default mac-right-option-modifier nil)
  (use-package simple-mpc
    ;;(when (fboundp 'evil-mode)
    ;;  (general-nmap :prefix belak/evil-leader
    ;;                "m" 'simple-mpc))
    :config
    (progn
      ;; (spacemacs/set-leader-keys
      ;;   "oa" 'simple-mpc)
      (when (fboundp 'evil-mode)
        (add-hook 'simple-mpc-mode-hook 'evil-emacs-state))

      (defun my-simple-mpc/state ()
        (propertize "" 'face '(:foreground "#b262af")))

      (defun my-simple-mpc/title (offset)
        (let* ((idx (simple-mpc-get-current-playlist-position))
               (pos (+ idx offset))
               (songs (split-string (shell-command-to-string "mpc playlist") "\n"))
               (title (when (> pos 0) (nth-value (1- pos) songs))))
          (propertize (or title "") 'face (when (/= offset 0) '(:foreground "#868dd9")))))

      (defhydra hydra-simple-mpc
        (:body-pre (setq hydra-is-helpful t)
                   :post (setq hydra-is-helpful nil)
                   :hint nil
                   :color amaranth)
        (concat "\n"
                "%s(my-simple-mpc/title -1)" "\n"
                "    %s(my-simple-mpc/state) %s(my-simple-mpc/title 0)" "\n"
                "%s(my-simple-mpc/title 1)" "\n")

        ("<down>" simple-mpc-next)

        ("<up>" simple-mpc-prev)

        ("<left>" simple-mpc-seek-backward)

        ("<right>" simple-mpc-seek-forward)

        ;; this is the default simple-mpc keybind
        ("c" simple-mpc-view-current-playlist :color blue)
        ("s" simple-mpc-query :color blue)
        ("t" simple-mpc-toggle)
        ("SPC" simple-mpc-toggle :color blue)

        ("q" nil :color blue))
      ))


    ; Targets include this file and any file contributing to the agenda - up to 9 levels deep
    (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                     (org-agenda-files :maxlevel . 9))))

    ; Use full outline paths for refile targets - we file directly with IDO
    (setq org-refile-use-outline-path t)

    ; Targets complete directly with IDO
    (setq org-outline-path-complete-in-steps nil)

    ; Allow refile to create parent tasks with confirmation
    (setq org-refile-allow-creating-parent-nodes (quote confirm))

    ;; ; Use IDO for both buffer and file completion and ido-everywhere to t
    ;; (setq org-completion-use-ido t)
    ;; (setq ido-everywhere t)
    ;; (setq ido-max-directory-size 100000)
    ;; (ido-mode (quote both))

    ;; ; Use the current window when visiting files and buffers with ido
    ;; (setq ido-default-file-method 'selected-window)
    ;; (setq ido-default-buffer-method 'selected-window)

    ; Use the current window for indirect buffer display
    (setq org-indirect-buffer-display 'current-window)

    ; Refile settings
    ; Exclude DONE state tasks from refile targets

    (defun bh/verify-refile-target ()
      "Exclude todo keywords with a done state from refile targets"
      (not (member (nth 2 (org-heading-components)) org-done-keywords)))

    (setq org-refile-target-verify-function 'bh/verify-refile-target)

    (defvar my-link-search-directory "~/org/wiki")

    (add-hook
     'org-open-at-point-functions
     'my-open-link-function)
    "This is were you can ultimately override default Spacemacs configuration.
 This function is called at the very end of Spacemacs initialization."
  ;; use O as org global bindings
  ;;   (setq org-wiki-location-list
  ;;         '(
  ;;           "~/org/wiki"    ;; First wiki (root directory) is the default.
  ;;           ))
  ;;   (setq org-wiki-completion-backend "vertico")
  ;;   (setq org-wiki-location "~/org/wiki")
  ;; (evil-leader/set-key
  ;;   "Oi" 'org-wiki-index
  ;;   "Oa" 'org-agenda
  ;;   "Og" 'helm-org-agenda-files-headings
  ;;   "Oo" 'org-clock-out
  ;;   "Oc" 'org-capture
  ;;   "OC" 'helm-org-capture-templates ;requires templates to be defined.
  ;;   "Ol" 'org-store-link)

  (setq markdown-command "markdown")
  ;; (setq markdown-css-dir "~/.emacs.d/markdown-css/")

  ;; (setq css-theme (expand-file-name  "~/.emacs.d/markdown-css/css/clearness.css"))
  (setq markdown-css-paths (list
                            (concat "file:///" (expand-file-name "~/.emacs.d/css/github-markdown.css"))
                            (concat "file:///" (expand-file-name "~/.emacs.d/css/hljs-github.min.css"))
                            (concat "file:///" (expand-file-name "~/.emacs.d/css/pilcrow.css"))
                            ))
  ;; (setq markdown-css-paths '("~/css/clearness.css"))
  ;; (setq markdown-css-theme "clearness")
  ;; (setq-default git-enable-github-support t)
  ;; (setq-default git-magit-status-fullscreen t)
  (setq powerline-default-separator 'bar)
  ;; (setq powerline-default-theme 'center)
  ;; (setq powerline-default-separator 'nil))

  (setq magit-repo-dirs '("~/git/"))
  ;; (setq-default dotspacemacs-themes '(smyx))
  ;; (setq-default
  ;; ;; Default theme applied at startup
  ;; (setq-default dotspacemacs-default-theme 'zenburn)

  (setq alert-default-style 'toaster)


  (setq go-format-before-save t)
  (setq-default
    ;; js2-mode
    js2-basic-offset 2
    js2-indent-switch-body t
    js-indent-level 2
    js2-include-node-externs t

    ;; web-mode
    css-indent-level 2
    css-indent-offset 2
    web-mode-markup-indent-offset 2
    web-mode-css-indent-offset 2
    web-mode-code-indent-offset 2
    web-mode-attr-indent-offset 2
    js-indent-level 2
    ruby-indent-level 2
    html-indent-level 2

    web-mode-code-indent-offset 2
    web-mode-css-indent-offset 2
    web-mode-enable-auto-indentation t
    web-mode-indent-style 2
    web-mode-markup-indent-offset 2
    web-mode-sql-indent-offset 2
    web-mode-code-indent-offset 2
    web-mode-markup-indent-offset 2


    ;; python-indent-offset 4
    ;; tab-width 2
    ;; evil-shift-width 2
    ;; indent-tabs-mode nil
    )
  ;; Setting and showing the 80-character column width
  ;; (setq mac-option-modifier 'none)
  ;; (set-fill-column 80)
  ;; (auto-fill-mode t)
  (add-hook 'groovy-mode-hook
    (lambda ()
      (setq c-basic-offset 4
        tab-width 4)))

  (add-hook 'java-mode-hook
    (lambda ()
      (setq c-basic-offset 4
        tab-width 4)))

  ;; python hooks
  (add-hook 'python-mode-hook
    (lambda ()
      ;; enable fill column indicator
      ;; (fci-mode t)
      (setq python-indent-offset 4)
      ;; enable automatic line wrapping at fill column
      (auto-fill-mode t)))
  (with-eval-after-load 'web-mode
    (add-to-list 'web-mode-indentation-params '("lineup-args" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-concats" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-calls" . nil)))
  (setq golden-ratio-adjust-factor .9
        golden-ratio-wide-adjust-factor .9)

  (setq reftex-default-bibliography '("~/org/bibliography/references.bib"))

  (defun artist-mode-toggle-emacs-state ()
    (if artist-mode
        (evil-emacs-state)
      (evil-exit-emacs-state)))

  (unless (eq dotspacemacs-editing-style 'emacs)
    (add-hook 'artist-mode-hook #'artist-mode-toggle-emacs-state))

  ;; (defun nolinum ()
  ;;   (global-nlinum-mode 0)
  ;;   )
  ;; (add-hook 'org-mode-hook 'nolinum)

  ;; change default key bindings (if you want) here
  (setq evil-replace-with-register-key (kbd "gr"))
  (evil-replace-with-register-install)

  (add-hook 'ruby-mode-hook
    (lambda ()
      (set (make-local-variable 'compile-command)
        (concat "ruby " buffer-file-name))))

  (add-to-list 'auto-mode-alist '("\\.js\\'" . react-mode))
  (setq exec-path-from-shell-check-startup-files nil)
  (setq-default evil-escape-key-sequence "jk")
  (setq paradox-github-token "7693224097823e845d1f39f82ba5fea5a7ae5531")
  (set-face-attribute 'default nil :family "xos4 Terminess Powerline")
  ; (set-fontset-font "fontset-default" 'unicode (font-spec :name "Symbola") nil 'append)

  (load "~/.spacemacs-secrets.el.gpg")

  ;; (with-eval-after-load 'python
  ;;   (add-hook 'python-mode-hook (lambda () (setq python-shell-interpreter "python3"))))

  ;; (defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
  ;;   "Workaround sgml-mode and follow airbnb component style."
  ;;   (let* ((cur-line (buffer-substring-no-properties
  ;;                      (line-beginning-position)
  ;;                      (line-end-position))))
  ;;     (if (string-match "^\\( +\\)\/?> *$" cur-line)
  ;;       (let* ((empty-spaces (match-string 1 cur-line)))
  ;;         (replace-regexp empty-spaces
  ;;           (make-string (- (length empty-spaces) sgml-basic-offset) 32)
  ;;           nil
  ;;           (line-beginning-position) (line-end-position))))))
  (defun js-jsx-indent-line-align-closing-bracket ()
    "Workaround sgml-mode and align closing bracket with opening bracket"
    (save-excursion
      (beginning-of-line)
      (when (looking-at-p "^ +\/?> *$")
        (delete-char sgml-basic-offset))))
  (advice-add #'js-jsx-indent-line :after #'js-jsx-indent-line-align-closing-bracket)


  ;; Temporary fix for M-RET bug : https://github.com/syl20bnr/spacemacs/issues/9603#issuecomment-332128487
  (org-defkey org-mode-map [(meta return)] 'org-meta-return)
  ;; (add-hook 'org-mode-hook (lambda()
  ;;                            (define-key
  ;;                              evil-normal-state-local-map
  ;;                              (kbd "M-RET")
  ;;                              #'org-meta-return)
  ;;                            (define-key
  ;;                              evil-insert-state-local-map
  ;;                              (kbd "M-RET")
  ;;                              #'org-meta-return)))


;; working terraform LSP
  ;; (lsp-register-client
  ;;   (make-lsp-client :new-connection (lsp-stdio-connection '("/home/timebomb/.asdf/shims/terraform-ls" "serve"))
  ;;     :major-modes '(terraform-mode)
  ;;     :server-id 'terraform-ls))

  ;; (add-hook 'terraform-mode-hook #'lsp-deferred)

  (term-init)
  (evil-init)

  (setenv "WORKON_HOME" "~/.cache/pypoetry/virtualenvs")

  )

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
