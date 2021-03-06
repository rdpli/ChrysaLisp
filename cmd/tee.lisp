;imports
(import 'class/lisp.inc)
(import 'cmd/options.inc)

(defq usage `(
(("-h" "--help")
"Usage: tee [options] [path] ...
	options:
		-h --help: this help info.
	Read from stdin, write to stdout and all given paths.")
))

;initialize pipe details and command args, abort on error
(when (and (defq slave (create-slave)) (defq args (options slave usage)))
	(defq stdin (file-stream 'stdin) buffer (string-stream (cat "")))
	(while (defq c (read-char stdin))
		(write buffer (prin (char c))))
	(setq buffer (str buffer))
	(each (lambda (_)
		(save buffer _)) (slice 1 -1 args)))
