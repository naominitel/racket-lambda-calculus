#lang racket

;; language module for the λ-calculus racket.
;; subset of racket containing just enough constructions
;; the standard λ-calculus definitions

;; the only forms we provide: λ, a simplified let (see below),
;; and literals (including quoted data)

(provide λ)
(provide lambda)
(provide let)
(provide quote)
(provide #%datum)

;; those seems to be required for any racket module

(provide #%app)
(provide #%module-begin)
(provide #%top)
(provide #%top-interaction)

;; simple let syntax that only allows binding to a single variable
;; we also prevent recursive definition.

(define-syntax (let stx)
  (define (is-lambda? stx)
    (and (list? stx)
         (not (null? stx))
         (identifier? (car stx))
         (or (bound-identifier=? (car stx) #'λ)
             (bound-identifier=? (car stx) #'lambda))))

  (define (lambda-bindings stx)
    (let ((args (syntax-e (cadr stx))))
      (if (identifier? args) (list args)
        (filter identifier? args))))

  (define (check-free stx id)
    (let ((e (syntax-e stx)))
      (cond
        ((identifier? stx) (if (bound-identifier=? stx id) stx #f))
        ((is-lambda? e) (and (null? (filter (λ (i) (bound-identifier=? i id)) (lambda-bindings e)))
                             (ormap (λ (x) (check-free x id)) (cddr e))))
        ((list? e) (ormap (λ (stx) (check-free stx id)) e))
        (else #f))))

  (syntax-case stx ()
    [(_ id expr) (identifier? #'id)
     (let ((free (check-free #'expr #'id)))
       (if free
         (raise-syntax-error #f "recursive definitions are not allowed" free #'expr)
         #'(define id expr)))]))

;; standard functions to convert between racket native types
;; (integers, lists... ) and the equivalent λ-calculus representation

(provide of-int)
(provide to-int)
(provide of-list)
(provide to-list)

;; those are not exported

(define O (λ (f x) x))
(define succ (λ (n) (λ (f x) (f (n f x)))))

(define null (λ (f x) x))
(define cons (λ (x y) (λ (f e) (f x (y f e)))))

(define (of-int x)
  (if (= x 0) O
      (succ (of-int (- x 1)))))

(define (to-int n)
  (n (λ (x) (+ x 1)) 0))

(define of-list
  (λ l (if (null? l) null
           (cons (first l) (apply of-list (rest l))))))

(define (to-list l)
  (l (λ (x y) `(,x ,@y)) '()))

;; macro to have correct semantics for the if encoding in λ-calculus
;; we have to add some "lazyness" arounds the operands

(provide (rename-out (if-syntax if)))

(define-syntax if-syntax
  (syntax-rules ()
    ((_ econd etrue efalse)
     ((econd (λ () etrue) (λ () efalse))))))
