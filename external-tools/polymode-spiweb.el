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
  :head-mode 'host
  :mode-matcher (cons "^\s*@[(|<].*@[)|>]\s+=\\+?\s+\\(\\w+\\)" 1))

;; (define-innermode poly-sphinxweb-escaped-innermode nil
;;   "Submode for literal text")

;;;###autoload (autoload #'poly-sphinxweb-mode "poly-sphinxweb")
(define-polymode poly-sphinxweb-mode
  :hostmode 'poly-sphinxweb-hostmode
  :innermodes '(poly-sphinxweb-innermode))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sphweb\\'" . poly-sphinxweb-mode))

(provide 'poly-sphinxweb)
