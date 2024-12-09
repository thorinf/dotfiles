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

;; evil mode
(use-package evil
  :config
  (evil-mode 1))

;; org mode
(use-package org
  :ensure t
  :config
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-ellipsis " ⬎"))
