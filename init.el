;; ========== Core Requirements ==========
(require 'json)
(require 'filenotify)
(require 'package)

;; ========== Theme: Hellwal Auto Loader ==========
(defvar my/hellwal-colors-file "~/.cache/hellwal/colors.json")
(defvar my/hellwal-colors-watch-descriptor nil)

(defun my/load-hellwal-colors ()
  "Load Hellwal colors from JSON file and apply to Emacs faces."
  (when (file-exists-p my/hellwal-colors-file)
    (let* ((json-object-type 'hash-table)
           (json-array-type 'list)
           (json-key-type 'string)
           (colors (json-read-file my/hellwal-colors-file))
           (special (gethash "special" colors))
           (colors-hash (gethash "colors" colors))
           (bg (gethash "background" special))
           (fg (gethash "foreground" special))
           (cursor (gethash "cursor" special))
           (color0  (gethash "color0" colors-hash))
           (color1  (gethash "color1" colors-hash))
           (color2  (gethash "color2" colors-hash))
           (color3  (gethash "color3" colors-hash))
           (color4  (gethash "color4" colors-hash))
           (color5  (gethash "color5" colors-hash))
           (color6  (gethash "color6" colors-hash))
           (color7  (gethash "color7" colors-hash))
           (color8  (gethash "color8" colors-hash))
           (color9  (gethash "color9" colors-hash))
           (color10 (gethash "color10" colors-hash))
           (color11 (gethash "color11" colors-hash))
           (color12 (gethash "color12" colors-hash))
           (color13 (gethash "color13" colors-hash))
           (color14 (gethash "color14" colors-hash))
           (color15 (gethash "color15" colors-hash)))
      
      ;; Apply colors to various faces
      (set-face-attribute 'mode-line nil
                          :foreground fg :background color1 :box nil)
      (set-face-attribute 'mode-line-inactive nil
                          :foreground fg :background bg :box nil)
      (set-face-attribute 'default nil
                          :foreground fg :background bg)
      (set-face-attribute 'cursor nil
                          :background cursor)
      (set-face-attribute 'region nil
                          :background color4 :foreground fg)
      (set-face-attribute 'highlight nil
                          :background color2 :foreground fg)
      (set-face-attribute 'minibuffer-prompt nil
                          :foreground color3 :weight 'bold)
      (set-face-attribute 'font-lock-comment-face nil
                          :foreground color6 :slant 'italic)
      (set-face-attribute 'font-lock-keyword-face nil
                          :foreground color3 :weight 'bold)
      (set-face-attribute 'font-lock-string-face nil
                          :foreground color7))))

(defun my/hellwal-colors-change-callback (event)
  "Callback triggered when colors.json changes."
  (message "Detected hellwal color change. Reloading...")
  (my/load-hellwal-colors))

(defun my/watch-hellwal-colors-file ()
  "Start watching hellwal colors.json for changes."
  (when (and (file-exists-p my/hellwal-colors-file)
             (not my/hellwal-colors-watch-descriptor))
    (setq my/hellwal-colors-watch-descriptor
          (file-notify-add-watch
           my/hellwal-colors-file
           '(change attribute-change)
           #'my/hellwal-colors-change-callback))))

(defun my/unwatch-hellwal-colors-file ()
  "Stop watching hellwal colors.json file."
  (when my/hellwal-colors-watch-descriptor
    (file-notify-rm-watch my/hellwal-colors-watch-descriptor)
    (setq my/hellwal-colors-watch-descriptor nil)))
(defvar my/backup-dir "~/.emacs.bkp/"
  "Directory to save automatic backups.")

;; Create directory if doesn't exist
(unless (file-exists-p my/backup-dir)
  (make-directory my/backup-dir t))

(defun my/save-buffer-backup ()
  "Saves a copy from the contents of the modifed buffer in the backup directory."
  (when (and buffer-file-name (buffer-modified-p))
    (let* ((filename (file-name-nondirectory buffer-file-name))
           (timestamp (format-time-string "%Y%m%d-%H%M%S"))
           (backup-name (concat my/backup-dir filename "_" timestamp ".bak")))
      (write-region (point-min) (point-max) backup-name nil 'silent)
      (message "Backup saved: %s" backup-name))))

;; Hook to save backups when the user stops for 5 seconds
(run-with-idle-timer 5 t #'my/save-buffer-backup)


(defun my/clean-old-backups (limit)
  "Kepp only the more recent files acordding to the limit"
  (let ((files (directory-files my/backup-dir t ".*\\.bak$")))
    (dolist (group (seq-group-by
                    (lambda (f) (car (split-string (file-name-nondirectory f) "_")))
                    files))
      (let ((sorted (sort (cdr group)
                          (lambda (a b) (time-less-p (nth 5 (file-attributes b))
                                                     (nth 5 (file-attributes a))))))
            (to-delete nil))
        (setq to-delete (nthcdr limit sorted))
        (dolist (f to-delete)
          (delete-file f))))))

;; Clean each hour (Can be called from M-x)
(run-with-timer 3600 3600 (lambda () (my/clean-old-backups 5)))
(defun baixar-logo-para-dashboard (url)
  "Baixa a imagem de URL e salva em /tmp/emacs-logo.png.
Depois configura o dashboard para usar essa imagem como logo."
  (let ((logo-path "/tmp/emacs-logo.png"))
    (url-copy-file url logo-path t) ;; t = sobrescrever se já existir
    (setq dashboard-startup-banner logo-path)
    (message "Logo do dashboard salva em: %s" logo-path)))

;; Initialize Hellwal theme
(my/load-hellwal-colors)
(my/watch-hellwal-colors-file)
(add-hook 'kill-emacs-hook #'my/unwatch-hellwal-colors-file)

;; ========== Performance Tweaks ==========
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

;; ========== UI Tweaks ==========
(tool-bar-mode   -1)
(menu-bar-mode   -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode t)
(global-hl-line-mode              t)
(global-visual-line-mode          t)
(add-hook 'c-mode-common-hook
          (lambda () (c-set-style "linux")))

(column-number-mode t)
(set-fringe-mode 0)

;; (setq-default tab-width 4)
;; Enable normal shift selection in Emacs
(setq shift-select-mode t)

;; Let Org respect shift-selection for normal text
(setq org-support-shift-select t)

;; Only disable M-Shift arrows for Org commands (keep normal Shift arrows for Org features)
(with-eval-after-load 'org
  ;; Unbind Meta+Shift+Arrow so it can extend selection normally
  (define-key org-mode-map (kbd "M-S-<left>") nil)
  (define-key org-mode-map (kbd "M-S-<right>") nil)
  (define-key org-mode-map (kbd "M-S-<up>") nil)
  (define-key org-mode-map (kbd "M-S-<down>") nil))
(setq org-src-window-setup 'current-window) ; mantém os resultados no mesmo buffer
(setq org-hide-block-startup t)             ; oculta blocos de código ao abrir

;; ========== File Handling ==========
(global-auto-revert-mode 1)
(setq backup-directory-alist `(("." . "~/.emacs.bkp")))
(setq org-hide-emphasis-markers t)

;; ========== Buffers ==========
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-x M-s") 'shell)

;; ========== Package Management ==========
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")
        ("elpa"  . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Optional: use-package (disabled by default)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))
;; Se ainda não estiver ativo
(setq org-startup-with-inline-images t)
;; Se necessário, especifique o executável Python
(setq org-babel-python-command "/usr/bin/python3")

;; ========== External Packages ==========
(require 'elcord)
(elcord-mode)

(require 'telephone-line)
(telephone-line-mode 1)

(use-package rainbow-mode
  :ensure t
  :hook ((prog-mode json-mode sh-mode conf-mode) . rainbow-mode))

(use-package persistent-scratch
  :ensure t
  :config
  (persistent-scratch-setup-default))

(use-package dashboard
  :ensure t
  :config
  ;; Baixa e seta a logo
  (baixar-logo-para-dashboard
   "https://umamusu.wiki/w/images/9/95/Agnes_Tachyon_%28Proto%29.png?download")

  ;; Outras configs do dashboard
  (setq dashboard-center-content t)
  (setq dashboard-set-footer nil)
  (dashboard-setup-startup-hook))

;; ========== Custom Variables ==========
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dashboard elcord ewal persistent-scratch rainbow-mode telephone-line)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Optional: load a theme (disabled by default)
;; (load-file "~/.emacs.d/themes/hellwal-theme.el")
;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; (load-theme 'hellwal-theme t)
