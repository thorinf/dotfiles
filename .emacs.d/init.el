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

(custom-set-variables '(package-selected-packages '(evil-org org-roam evil)))
(custom-set-faces)

(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle))
(evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle))
