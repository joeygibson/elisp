;; This buffer is for notes you don't want to save, and for Lisp evaluation.
;; If you want to create a file, visit that file with C-x C-f,
;; then enter the text in that file's own buffer.

(quote (1 2 3))
(list 1 (+ 1 1) 3)
`(1 ,(+ 1 1) 3)

(setq fruit '((apple . "red")
              (banana . "yellow")
              (orange . "orange")))
(car (car fruit))

;; = is numeric equality
;; /= is numeric inequality
;; (not ...) is for negating anything
;; eq is value equality; also works for integers
;; eql is float equality; just use =
;; equal is for deep, structural equality

(= 2 1)
(= 2 2)
(/= 2 1)
(eq 'foo 'foo)
(equal '(1 2 3) '(1 2 3))

;; String functions
(concat "foo" "bar" "baz") ; foobarbaz
(string= "foo" "baz") ; nil; just use (equal)
(substring "foobar" 0 3); foo
(upcase "foobar") ; FOOBAR

(string-to-number "3")                  ; 3
(number-to-string 23)                   ; "23"

;; Conditionals

(if (>= 3 2)
    (message "Hello"))

(if (today-is-friday)
    (message "Friday")
  (message "Nope"))

(if (zerop 0)
    (progn
      (do-something)
      (do-something-else)
      (etc-etc-etc)))

;; progn is only for the then-expr; the else-expr doesn't need it
(if (zerop 0)
    (message "Zero")
  (first-in-else)
  (second-in-else)
  (third-in-else))

;; if no else body, use when
(when (>= 3 2)
  (message "Yep"))

;; if no then body, use unless
(unless (>= 3 4)
  (message "Yep"))

;; the do-stuff sections have implicit progns, and don't need them added
;; default match is optional
(cond
 (test-1
  do-stuff-1)
 (test-2
  do-stuff-2)
 (t
  do-default-stuff))

;; the 'cl package provides (case), which is a little cleaner syntax
(case 12
  (5 "five")
  (1 "one")
  (12 "twelve")
  (otherwise "Something else"))

;; while works as expected
(setq x 10
      total 10)
(while (plusp x)
  (incf total x)
  (decf x))


;; break
(setq x 0
      total 0)
(catch 'break
  (while t
    (incf total x)
    (if (> (incf x) 10)
        (throw 'break total))))         ; 55

;; continue
(setq x 0
      total 0)
(while (< x 100)
  (catch 'continue
    (incf x)
    (if (zerop (% x 5))
        (throw 'continue nil))
    (incf total x)))

;; call in the Common Lisp package
(require 'cl)

;; do/while
(loop do
      (setq x (1+ x))
      while
      (< x 10))

;; Thie JavaScript...
;; var result = [];
;; for (var i = 10, j = 0; j <= 10; i--, j += 2) {
;;   result.push(i+j);
;; }
;; looks something like this Lisp
(loop with result = '()                 ; one-time initialization
      for i downfrom 10                 ; count i down from 10
      for j from 0 by 2                 ; count j up from 0 by 2
      while (< j 10)
      do
      (push (+ i j) result)
      finally
      return (nreverse result))         ; (10 11 12 13 14)

;; for x in bar...
(loop for i in '(1 2 3 4 5 6)
      collect (* i i))                  ; (1 4 9 16 25 36)

;; functions
(defun square (x)
  "Return x squared."
  (* x x))

(square 23232323344)                    ; 173583804162957568

;; no-arg function
(defun hello ()
  "Print the string 'hello' to the minibuffer"
  (message "Hello!"))

(hello)

;; Putting (interactive) so it can be called from M-x

;; locals
(let ((name1 value1)
      (name2 value2)
      name3
      name4
      (name5 value5)
      name6))

;; Emacs Lisp is dynamically scoped!!!
(defun foo ()
  (let ((x 6))
    (bar)
    x))

(defun bar ()
  (setq x 7))

(foo) ; 7

;; return values
(require 'calendar)

(defun day-name ()
  (let ((date (calendar-day-of-week
               (calendar-current-date))))
    (cond
     ((= date 0) "Sunday")
     ((= date 6) "Saturday")
     (t "Weekday"))))

(day-name)                              ; "Sunday"

;; early-return
(defun early-day-name ()
  (let ((date (calendar-day-of-week (calendar-current-date))))
    (catch 'return
      (case date
        (0 (throw 'return "Sunday"))
        (6 (throw 'return "Saturday"))
        (t (throw 'return "Weekday"))))))

(early-day-name)                        ; "Sunday"

;; conditions error-handling system
(condition-case nil
    (progn
      (do-something)
      (do-something-else))
  (error
   (message "Oh noes!")
   (do-recover-stuff)))

;; eat the exception
(ignore-errors
  (do-something)
  (do-something-else))

;; Elisp version of "finally"
(unwind-protect
    (progn
      (do-something)
      (do-something-else))
  (first-finally-expr)
  (second-finally-expr))

;; try/catch/finally
(unwind-protect
    (condition-case nil                 ; try
        (progn
          (do-something)
          (do-something-else))
      (error                            ; catch
       (message "Oh noes!")
       (poop-pants)))
  (first-finally-expr)                  ; finally 1
  (second-finally-expr))                ; finally 2

;; Classes - (require 'cl)
(defstruct person
  "A person structure"
  name
  (age 0)
  (height 0.0))

(make-person)                     ; [cl-struct-person nil 0 0.0]
(make-person :age 39)             ; [cl-struct-person nil 39 0.0]
(make-person :name "Steve"        
             :height 5.83         
             :age 39)             ; [cl-struct-person "Steve" 39 5.83]

;; defstruct supports single-inheritance, to arbitrary depth
(defstruct (employee (:include person))
  "An employee structure"
  company
  (level 1)
  (title "n00b"))

(make-employee :name "Frank") ; [cl-struct-employee "Frank" 0 0.0 nil 1 "n00b"]

;; defstruct creates instanceof-like functions
(person-p (make-person))                ; t
(employee-p (make-person))              ; nil
(employee-p (make-employee))            ; t
(person-p (make-employee))              ; t

;; Setting fields
(setq e (make-employee))
(setf (employee-name e) "Frank"
      (employee-age e) 85
      (employee-company e) "The Rat Pack")

(employee-name e)                       ; "Frank"
(person-age e)                          ; 85

;; Variables
(defconst pi 3.14159 "A gross aproximation of π")

;; Interactive
(defun yay ()
  "Insert 'Yay!' at cursor position"
  (interactive)
  (insert "Yay!"))
(yay)                                   ; Yay!

;; accept a universal-argument
(defun myfunction (arg)
  "Prints the argument"
  (interactive "p")
  (message "Your argument is %d" arg))
;; call with C-u 23 M-x myfunction => "Your argument is 23"

;; accept a region
(defun myRegionFunction (myStart myEnd)
  "Prints region start and end positions"
  (interactive "r")
  (message "Region starts at %d and ends at %d." myStart myEnd))
;; highlight a region and then M-x myRegionFunction

(interactive "nWhat is your age?")      ; prompt for number
(interactive "n")                       ; prompt for number
(interactive "sEnter a string")         ; prompt for string
(interactive "r")                       ; region


























