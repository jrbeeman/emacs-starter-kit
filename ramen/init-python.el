(add-hook 'python-mode-hook
          (lambda ()
            (define-key py-mode-map "\C-c\C-l" nil)
            (define-key py-mode-map "\C-c\C-r" 'py-execute-region)
            (define-key py-mode-map "\C-c\C-s" 'py-shell)
            (setq py-shell-switch-buffers-on-execute nil)
            (cond ((fboundp 'subword-mode) (subword-mode 1))
                  ((fboundp 'c-subword-mode) (c-subword-mode 1)))))
