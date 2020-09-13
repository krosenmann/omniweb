;;; poly-sphinxweb.el --- Polymode for SphinxWEB literate programming system

;; Version: 0.1

;;; Commentary:
;; 


;;; Code:

(require 'polymode)
(require 'rst)

(define-hostmode poly-sphinxweb-hostmode nil
  "SphinxWEB test hostmode"
  :mode 'rst-mode
)

(define-auto-innermode poly-sphinxweb-innermode nil
  "SphinxWEB text innermode."
  :head-matcher "^\s*@?[(|<].*@[)|>]\s*=\s*.*\n"
  :tail-matcher "^\s*@\s*$"
  :mode 'host
  :mode-matcher (cons "^\s*@[(|<].*@[)|>]\s+=\\+?\s+\\(\\w+\\)" 1))

;;;###autoload (autoload #'poly-sphinxweb-mode "poly-sphinxweb")
(define-polymode poly-sphinxweb-mode
  :hostmode 'poly-sphinxweb-hostmode
  :innermodes '(poly-sphinxweb-innermode))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sphweb\\'" . poly-sphinxweb-mode))

(provide 'poly-sphinxweb)

;;; poly-sphinxweb.el ends here
