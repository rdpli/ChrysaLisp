;imports
(import 'sys/lisp.inc)
(import 'class/lisp.inc)
(import 'gui/lisp.inc)

(defun-bind refresh-wallpaper ()
	;pick nearest wallpaper to screen size
	(bind '(w h) (view-get-size screen))
	(defq index 0 err max_int flag 0)
	(each (lambda ((iw ih it))
		(defq iw (- w iw) ih (- h ih) new_err (+ (* iw iw) (* ih ih)))
		(when (< new_err err)
			(setq err new_err index _ flag (if (= it 32) 0 view_flag_opaque)))) images_info)
	(view-sub wallpaper)
	(canvas-swap (canvas-resize (setq wallpaper (create-canvas w h 1))
		(canvas-load (elem index images) load_flag_noswap)))
	(gui-add-back (view-change (view-set-flags wallpaper
		(+ (const (+ view_flag_at_back view_flag_dirty_all)) flag)
		(const (+ view_flag_at_back view_flag_dirty_all view_flag_opaque))) 0 0 w h)))

(defq images '("apps/images/wallpaper.cpm" "apps/images/chrysalisp.cpm")
	images_info (map canvas-info images) wallpaper (create-view)
	screen (penv (gui-add-back wallpaper)))

(refresh-wallpaper)
(while t
	(when (and (< (get-long (defq msg (mail-read (task-mailbox))) ev_msg_target_id) 0)
			(= (get-long msg ev_msg_type) ev_type_gui))
		;resized GUI
		(refresh-wallpaper)))
