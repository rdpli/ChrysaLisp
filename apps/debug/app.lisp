;import settings
(run 'sys/lisp.inc)
(run 'gui/lisp.inc)

;single instance only
(unless (mail-enquire "DEBUG_SERVICE")
	(kernel-declare "DEBUG_SERVICE" (task-mailbox))

(structure 'debug_msg 0
	(long 'command)
	(long 'reply_id)
	(long 'tcb)
	(offset 'data))

(structure 'event 0
	(byte 'win_debug)
	(byte 'win_play)
	(byte 'win_pause)
	(byte 'win_step)
	(byte 'win_clear)
	(byte 'win_play_all)
	(byte 'win_pause_all)
	(byte 'win_step_all)
	(byte 'win_clear_all)
	(byte 'win_hvalue))

(defq vdu_width 60 vdu_height 30 vdu_index nil vdu_keys (list) vdu_list (list))

(ui-tree window (create-window window_flag_status) ('color 0xc0000000)
	(ui-element _ (create-flow) ('flow_flags (bit-or flow_flag_down flow_flag_fillw))
		(ui-element _ (create-flow) ('flow_flags (bit-or flow_flag_right flow_flag_fillh)
				'color 0xff00ff00 'font (create-font "fonts/Entypo.otf" 32))
			(button-connect-click (ui-element _ (create-button) ('text "")) event_win_play)
			(button-connect-click (ui-element _ (create-button) ('text "")) event_win_pause)
			(button-connect-click (ui-element _ (create-button) ('text "")) event_win_step)
			(button-connect-click (ui-element _ (create-button) ('text "")) event_win_clear)
			(button-connect-click (ui-element _ (create-button) ('color 0xff00ffff 'text "")) event_win_play_all)
			(button-connect-click (ui-element _ (create-button) ('color 0xff00ffff 'text "")) event_win_pause_all)
			(button-connect-click (ui-element _ (create-button) ('color 0xff00ffff 'text "")) event_win_step_all)
			(button-connect-click (ui-element _ (create-button) ('color 0xff00ffff 'text "")) event_win_clear_all))
		(slider-connect-value (ui-element hslider (create-slider) ('value 0 'color 0xffff0000)) event_win_hvalue)
		(ui-element vdu_flow (create-flow) ('flow_flags (bit-or flow_flag_fillw flow_flag_fillh)
				'text_color 0xffffff00 'font (create-font "fonts/Hack-Regular.ttf" 16)
				'vdu_width vdu_width 'vdu_height vdu_height)
			(ui-element vdu (create-vdu)))))

(window-set-title window "Debug")
(window-set-status window "Ready")
(bind '(w h) (view-pref-size window))
(gui-add (view-change window 0 0 w h))

(defun set-slider-values ()
	(defq val (get hslider 'value) mho (max 0 (dec (length vdu_list))))
	(def hslider 'maximum mho 'portion 1 'value (min val mho))
	(view-dirty hslider))

(defun play (_)
	(unless (elem 1 _)
		(mail-send "" (elem 2 _))
		(elem-set 2 _ nil))
	(elem-set 1 _ t))

(defun pause (_)
	(elem-set 1 _ nil))

(defun step (_)
	(when (elem 2 _)
		(mail-send "" (elem 2 _))
		(elem-set 2 _ nil))
	(elem-set 1 _ nil))

(defun reset (&optional _)
	(setd _ -1)
	(if (le 0 _ (dec (length vdu_list)))
		(progn
			(def hslider 'value _)
			(view-sub vdu)
			(view-dirty (view-layout (view-add-back vdu_flow
				(setq vdu (elem 0 (elem (setq vdu_index _) vdu_list)))))))
		(progn
			(clear vdu_list)
			(clear vdu_keys)
			(setq vdu_index nil)
			(view-sub vdu)
			(view-dirty (view-layout (view-add-back vdu_flow (setq vdu (create-vdu)))))
			(vdu-print vdu (cat
				"ChrysaLisp Debug 0.2" (char 10)
				"Green buttons act on a single task." (char 10)
				"Cyan buttons act on all tasks." (char 10)
				"Red slider to switch between tasks." (char 10)
				"Add (debug [form] ...) statements in your source." (char 10)
				"Try (debug (env)) in functions etc." (char 10)))))
	(set-slider-values))

(reset)
(while t
	(cond
		;new debug msg
		((eq (defq id (read-long ev_msg_target_id (defq msg (mail-mymail)))) event_win_debug)
			(defq reply_id (read-long debug_msg_reply_id msg)
				tcb (read-long debug_msg_tcb msg)
				data (read-cstr debug_msg_data msg)
				key (sym-cat (str (bit-shr reply_id 32)) (str tcb))
				index (find key vdu_keys))
			(unless index
				(def (defq new_vdu (create-vdu)) 'vdu_width vdu_width 'vdu_height vdu_height
					'font (create-font "fonts/Hack-Regular.ttf" 16))
				(push vdu_keys key)
				(push vdu_list (list (view-layout new_vdu) nil nil))
				(setq index (dec (length vdu_list)))
				(unless vdu_index
					(view-sub vdu)
					(view-dirty (view-layout (view-add-back vdu_flow (setq vdu new_vdu))))
					(setq vdu_index index))
				(set-slider-values))
			(defq vdu_rec (elem index vdu_list))
			(vdu-print (elem 0 vdu_rec) data)
			(if (elem 1 vdu_rec)
				(mail-send "" reply_id)
				(elem-set 2 vdu_rec reply_id)))
		;moved task slider
		((eq id event_win_hvalue)
			(when vdu_index
				(reset (get hslider 'value))))
		;pressed play button
		((eq id event_win_play)
			(when vdu_index
				(play (elem vdu_index vdu_list))))
		;pressed pause button
		((eq id event_win_pause)
			(when vdu_index
				(pause (elem vdu_index vdu_list))))
		;pressed step button
		((eq id event_win_step)
			(when vdu_index
				(step (elem vdu_index vdu_list))))
		;pressed clear button
		((eq id event_win_clear)
			(when vdu_index
				(step (elem vdu_index vdu_list))
				(setq vdu_keys (cat (slice 0 vdu_index vdu_keys) (slice (inc vdu_index) -1 vdu_keys)))
				(setq vdu_list (cat (slice 0 vdu_index vdu_list) (slice (inc vdu_index) -1 vdu_list)))
				(reset 0)))
		;pressed play all button
		((eq id event_win_play_all)
			(each play vdu_list))
		;pressed pause all button
		((eq id event_win_pause_all)
			(each pause vdu_list))
		;pressed step all button
		((eq id event_win_step_all)
			(each step vdu_list))
		;pressed clear all button
		((eq id event_win_clear_all)
			(each step vdu_list)
			(reset))
		;otherwise
		(t (view-event window msg))))
)