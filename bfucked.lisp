;;;; bfucked.lisp

(in-package #:bfucked)

(defvar *plus* '('((setf (aref data pos) (ldb (byte 8 0) (1+ (aref data pos)))))))
(defvar *minus* '('((setf (aref data pos) (ldb (byte 8 0) (1- (aref data pos)))))))
(defvar *right* '('((incf pos))))
(defvar *left* '('((decf pos))))
(defvar *stop* '('((princ (code-char (aref data pos))))))
(defvar *comma* '('((setf (aref data pos) (char-code (read-char))))))
(defvar *open* '((setf s (gensym "open"))
                      (setf c (gensym "close"))
                      (push c stack)
                      (push s stack)
                      `((when (= 0 (aref data pos))
                          (go ,c))
                        ,s)))
(defvar *close* '((setf s (pop stack))
                       (setf c (pop stack))
                       `((unless (= (aref data pos) 0)
                           (go ,s))
                         ,c)))
(defvar *debug* '('((loop for i from (- pos 3) to (+ pos 3) do (format t "~a~%" (aref data i))))))

(defmacro mkcompiler ()
  `(defun bfcompile (str &aux
                           (stack (list))
                           s
                           c)
    `(let ((pos 30000)
           (data (make-array 60000
                             :element-type '(unsigned-byte 8)
                             :initial-element 0)))
       (tagbody
          ,@(loop :for char :across str
                  :appending (switch (char)
                               (#\+ ,@*plus*)
                               (#\- ,@*minus*)
                               (#\> ,@*right*)
                               (#\< ,@*left*)
                               (#\. ,@*stop*)
                               (#\, ,@*comma*)
                               (#\[ ,@*open*)
                               (#\] ,@*close*)
                               (#\% ,@*debug*)))))))
(mkcompiler)
(defmacro brainfuck (str)
  (bfcompile str))
