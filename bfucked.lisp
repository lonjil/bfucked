;;;; bfucked.lisp

(in-package #:bfucked)

; iptr

(defconstant +plus+ '('((incf (aref data pos)))))
(defconstant +minus+ '('((decf (aref data pos)))))
(defconstant +right+ '('((incf pos))))
(defconstant +left+ '('((decf pos))))
(defconstant +stop+ '('((princ (code-char (aref data pos))))))
(defconstant +comma+ '('((setf (aref data pos) (char-code (read-char))))))
(defconstant +open+ '((setf s (gensym "open"))
                      (setf c (gensym "close"))
                      (push c stack)
                      (push s stack)
                      `((when (= 0 (aref data pos))
                          (go ,c))
                        ,s)))
(defconstant +close+ '((setf s (pop stack))
                       (setf c (pop stack))
                       `((when (= (aref data pos) 0)
                           (go ,s))
                         ,c)))

(defmacro mkcompiler ()
  `(defun bfcompile (str &aux
                           (stack (list))
                           s
                           c)
    `(let ((pos 0)
           (data (make-array 30000
                             :element-type '(signed-byte 8)
                             :initial-element 0)))
       (tagbody
          ,@(loop :for c :across str
                  :appending (switch (c)
                               (#\+ ,@+plus+)
                               (#\- ,@+minus+)
                               (#\> ,@+right+)
                               (#\< ,@+left+)
                               (#\. ,@+stop+)
                               (#\, ,@+comma+)
                               (#\[ ,@+open+)
                               (#\] ,@+close+)))))))
(mkcompiler)
(defmacro brainfuck (str)
  (bfcompile str))
