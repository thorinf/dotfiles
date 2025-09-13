;; initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))
(package-initialize)

;; install `use-package` if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; always ensure packages are installed
(require 'use-package)
(setq use-package-always-ensure t)

;; force terminal mode
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; evil mode (vim emulation)
(use-package evil
  :config
  (evil-mode 1))

;; org mode configuration
(use-package org
  :ensure t
  :config
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-ellipsis " ⬎"))

;; evil-org integration for better navigation
(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar)))

;; enable org-indent-mode for cleaner structure visualization
(add-hook 'org-mode-hook #'org-indent-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(evil-org org-roam evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle))
