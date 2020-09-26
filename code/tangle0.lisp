(ql:quickload 'cl-ppcre)


(defparameter *re-storage* (make-hash-table :test 'eq))


(defun dump-re-str (name re-str)
  (let ((re-place (gethash name *re-storage*)))
    (when re-place
      (error (format 'nil "Regexp with name \"~A\" already defined!~%" name)))
    (setf (gethash name *re-storage*) re-str)))


(defun re-str (key)
  (gethash key *re-storage*))

(defmacro defscanner  (name re-str)
    `(progn
       (dump-re-str (symbol-name ',name) ,re-str)
       (defconstant ,name (ppcre:create-scanner ,re-str)))
  )

(defun re-concat (&rest scanners)
  (apply #'concatenate 'string 
               (mapcar #'(lambda (sym) (re-str (symbol-name sym)))
                    scanners)))


(defclass chunk ()
  ((name :initarg :name
         :accessor name)
   (code :initform nil
         :accessor code)
   (link :initarg :link
         :accessor link)
   (storage :initarg :storage
            :accessor storage)
   (appears-in :initform nil
               :accessor appears-in)
   (contains :initform nil
             :accessor contains)
   (language :initarg :language 
             :accessor language)
   (file :initarg :file
         :accessor file)))


(defparameter *file-chunks* (make-hash-table :test 'equal))


(defparameter *chunks* (make-hash-table :test 'equal))


(defun get-file-chunk (name)
  (gethash name *file-chunks*))


(defun get-chunk (name)
  (gethash name *chunks*))


(defun create-chunk (new-chunk)
  (let* ((chunk-storage (storage new-chunk))
         (exists? (gethash (name new-chunk) chunk-storage)))
    (when exists?
      (error "Chunk \"~A\" already defined in ~A:~A~%" (name new-chunk) (file exists?) (link exists?)))
    (setf (gethash (name new-chunk) chunk-storage) new-chunk)))


(defun append-chunk (appendix)
  (let* ((storage* (storage appendix))
        (for-extension (gethash (name appendix) storage*)))

    ;; Errors
    (unless for-extension
      (error "Chunk ~A undefined. ~A~%" (name appendix) (file appendinx)))
    (let ((initial-file (file for-extension))
          (appendix-file (file appendix)))
      (when (not (equal initial-file appendix-file))
        (error (format 'nil "Multifile expansion! Chunk defined in ~A but expands in ~A"
                     initial-file appendix-file))))

    ;; Now actual append
    (progn
      (setf (link for-extension) (append (link for-extension) (link appendix)))
      (setf (code for-extension) (append (code for-extension) (code appendix))))))




(defscanner +chunk-name+ "^@<([^>]+)@>")
(defscanner +file-name+ "^@\\(([^)]+)@\\)")
(defscanner +operation+ "\\s*(=\\+?)\\s*")
(defscanner +language+ "([\\S]+)\\s*$")
(defscanner +end-of-chunk+ "^@\\s*$")

(defscanner +chunk-definition+
  (re-concat '+chunk-name+ '+operation+ '+language+))

(defscanner +filechunk-definition+
  (re-concat '+file-name+ '+operation+ '+language+))


(defun read-this-file (filename)
  (let ((lino 0))
    (mapcar #'(lambda (line) (list (incf lino) filename line)) 
            (uiop:read-file-lines filename)))
   )


(defun parse-header (line)
  (let ((content (nth 2 line))
        (lino (nth 0 line))
        (filename (nth 1 line)))
    (ppcre:register-groups-bind (name op language)
        (+chunk-definition+ content)
      (list 
       (if (equal op "=") 'create-chunk 'append-chunk)
       (make-instance 'chunk
                      :name name
                      :language language
                      :storage *chunks*
                      :file filename
                      :link (list lino)
                      )))
    ))


(defun parse-file-header (line)
  (let ((content (nth 2 line))
        (lino (nth 0 line))
        (filename (nth 1 line)))
    (ppcre:register-groups-bind (name op language)
        (+filechunk-definition+ content)
      (list
       (if (equal op "=") '!create-chunk '!append-chunk)
       (make-instance 'chunk
                      :name name
                      :language language
                      :storage *file-chunks*
                      :file filename
                      :link (list lino))))
    ))


(defun eoc? (line)
  (ppcre:scan +end-of-chunk+ line))


(defun extract-chunks (lines)
  (let ((chunk-mode? 'nil)
        (buff 'nil)
        (op 'nil)
        (current-chunk 'nil))

    (dolist (line lines)
      (let ((header (or (parse-header line)
                        (parse-file-header line)))
            (eoc (eoc? (nth 2 line))))
        (cond
          (eoc (progn
                 (setf (code current-chunk) buff)
                 (apply op (list current-chunk))
                 (setf chunk-mode? 'nil)
                 (setf buff '())
                 (setf op 'nil)))
          (header (progn
                    (setf op (car header))
                    (setf current-chunk (cadr header))
                    (setf chunk-mode? t)
                    (format t "Header: ~A ~%" header)
                    ))
          (chunk-mode? (setf buff (append buff (list (nth 2 line))))))
          ))
    ))

