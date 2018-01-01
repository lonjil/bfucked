;;;; bfucked.lisp

(in-package #:bfucked)

(defvar *plus* '('((setf (aref data pos) (ldb (byte 8 0) (1+ (aref data pos)))))))
(defvar *minus* '('((setf (aref data pos) (ldb (byte 8 0) (1- (aref data pos)))))))
(defvar *right* '('((incf pos))))
(defvar *left* '('((decf pos))))
(defvar *stop* '('((princ (code-char (aref data pos))))))
(defvar *comma* '('((setf (aref data pos) (char-code (read-char))))))
(defvar *open* '((let ((s (gensym "open"))
                       (c (gensym "close")))
                   (push c stack)
                   (push s stack)
                   `(,s
                     (when (= 0 (aref data pos))
                       (go ,c))))))
(defvar *close* '((let ((s (pop stack))
                        (c (pop stack)))
                    `((go ,s)
                      ,c))))
(defvar *debug* '('((loop for i from (- pos 3) to (+ pos 3) do (format t "~a~%" (aref data i))))))

(defmacro mkcompiler ()
  `(defun bfcompile (str)
     (let* ((inline-input nil)
            (stack (list))
            (compiled `(let ((pos 30000)
                             (data (make-array 60000
                                               :element-type '(unsigned-byte 8)
                                               :initial-element 0)))
                         (tagbody
                            ,@(loop :for char :across str
                                    :for i :from 0
                                    :append (switch (char)
                                              (#\+ ,@*plus*)
                                              (#\- ,@*minus*)
                                              (#\> ,@*right*)
                                              (#\< ,@*left*)
                                              (#\. ,@*stop*)
                                              (#\, ,@*comma*)
                                              (#\[ ,@*open*)
                                              (#\] ,@*close*)
                                              (#\% ,@*debug*))
                                      :until (and (char= char #\!)
                                                  (setf inline-input (1+ i)))
       (if inline-input
           `(with-input-from-string (*standard-input* ,(subseq str inline-input))
              ,compiled)
           compiled))))
(mkcompiler)
(defmacro brainfuck (str)
  (bfcompile str))
