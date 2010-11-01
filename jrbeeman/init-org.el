;; basic setup
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-log-done t)

(setq message-mode-hook
      (quote (orgstruct++-mode
              (lambda nil (setq fill-column 72))
              turn-on-auto-fill
              bbdb-define-all-aliases)))

(add-hook 'org-mode-hook
          (lambda ()
            ;; Disable flyspell for org mode
            (flyspell-mode 0)
            (auto-fill-mode 0)
            (visual-line-mode 1)))

;; Tasks and states
(setq org-todo-keywords (quote (
 (sequence "TODO(t)" "STARTED(s!)" "|" "DONE(d!/!)")
 (sequence "WAITING(w@/!)" "SOMEDAY(S!)" "OPEN(O@)" "TASK(a@/!)" "|" "CANCELLED(c@/!)")
 (sequence "QUOTE(q!)" "QUOTED(Q!)" "|" "APPROVED(A@)" "EXPIRED(E@)" "REJECTED(R@)"))))

(setq org-todo-keyword-faces (quote (("TODO" :foreground "red" :weight bold)
 ("STARTED" :foreground "blue" :weight bold)
 ("DONE" :foreground "forest green" :weight bold)
 ("WAITING" :foreground "orange" :weight bold)
 ("SOMEDAY" :foreground "magenta" :weight bold)
 ("CANCELLED" :foreground "forest green" :weight bold)
 ("QUOTE" :foreground "red" :weight bold)
 ("QUOTED" :foreground "magenta" :weight bold)
 ("APPROVED" :foreground "forest green" :weight bold)
 ("EXPIRED" :foreground "forest green" :weight bold)
 ("REJECTED" :foreground "forest green" :weight bold)
 ("OPEN" :foreground "blue" :weight bold)
 ("TASK" :foreground "blue" :weight bold))))

;; Fast Todo selection / state change
(setq org-use-fast-todo-selection t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

;; Todo state triggers
(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t) ("NEXT"))
              ("SOMEDAY" ("WAITING" . t))
              (done ("NEXT") ("WAITING"))
              ("TODO" ("WAITING") ("CANCELLED"))
              ("STARTED" ("WAITING") ("NEXT" . t))
              ("TASK" ("WAITING") ("NEXT" .t)))))

;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")

(defun my-start-clock-if-needed ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward " *:CLOCK-IN: *" nil t)
      (replace-match "")
      (org-clock-in))))

;; Keep clocks running
(setq org-remember-clock-out-on-exit nil)

;; C-c C-c stores the note immediately
(setq org-remember-store-without-prompt t)

; Use IDO for target completion
(setq org-completion-use-ido t)

; Targets complete in steps so we start with filename, TAB shows the next level of targets etc
(setq org-outline-path-complete-in-steps t)

;; Custom agenda views
(setq org-agenda-custom-commands
      (quote (("s" "Started Tasks" todo "STARTED" ((org-agenda-todo-ignore-with-date nil)))
              ("w" "Tasks waiting on something" tags "WAITING/!" ((org-use-tag-inheritance nil)))
              ("r" "Refile New Notes and Tasks" tags "LEVEL=1+REFILE" ((org-agenda-todo-ignore-with-date nil)))
              ("N" "Notes" tags "NOTE" nil)
              ("n" "Next" tags "NEXT-WAITING-CANCELLED/!" nil))))

;; timeclock setup
;;
;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)
;;
;; Yes it's long... but more is better ;)
(setq org-clock-history-length 35)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")
;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Don't clock out when moving task to a done state
(setq org-clock-out-when-done nil)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)

;; stuck projects
(setq org-stuck-projects (quote ("LEVEL=2/!-DONE-CANCELLED-OPEN-SOMEDAY-WAITING" nil ("NEXT") "")))

;; Reminders

; Erase all reminders and rebuilt reminders for today from the agenda
(defun my-org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

; Rebuild the reminders everytime the agenda is displayed
(add-hook 'org-finalize-agenda-hook 'my-org-agenda-to-appt)

; This is at the end of my .emacs - so appointments are set up when Emacs starts
(my-org-agenda-to-appt)

; Activate appointments so we get notifications
(appt-activate t)

; If we leave Emacs running overnight - reset the appointments one minute after midnight
(run-at-time "24:01" nil 'my-org-agenda-to-appt)

;; Adding new tasks quickly without disturbing the current task content
(setq org-insert-heading-respect-content t)

;; Customize search results a bit
(setq org-show-following-heading t)
(setq org-show-hierarchy-above t)
(setq org-show-siblings nil)

;; Logging
(setq org-log-done (quote time))
(setq org-log-into-drawer t)

;; Special key handlers
(setq org-special-ctrl-a/e t)
(setq org-special-ctrl-k t)
(setq org-yank-adjusted-subtrees t)

(defun org-toggle-iimage-in-org ()
  "display images in your org file"
  (interactive)
  (if (face-underline-p 'org-link)
      (set-face-underline-p 'org-link nil)
      (set-face-underline-p 'org-link t))
  (iimage-mode))

;; Reftex
(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name)
       (file-exists-p (buffer-file-name))
       (reftex-parse-all))
  (define-key org-mode-map (kbd "C-c )") 'reftex-citation))
(add-hook 'org-mode-hook 'org-mode-reftex-setup)
