;import ui settings
(run 'apps/ui.lisp)

(defq app_list '(
	"apps/netmon/app"
	"apps/terminal/app"
	"apps/canvas/app"
	"apps/raymarch/app"
	"apps/calculator/app"
	"tests/farm"
	"tests/pipe"
	"tests/global"
	"tests/migrate")
	window (ui-window 0)
	flow (ui-flow))

(call slot_set_title window "Launcher")
(eval (list defq 'flow_flags (bit-or flow_flag_down flow_flag_fillw) 'color 0xffffff00) flow)
(each (lambda (_)
	(defq button (ui-button))
	(eval (list defq 'text _) button)
	(ui-connect-click button 0)
	(call slot_add_child flow button)) app_list)
(call slot_add_child window flow)
(bind '(w h) (ui-pref-size window))
(ui-change window 32 32 (add w 32) h)
(ui-add-to-screen window)

(while t
	(cond
		((ge (read-long ev_msg_target_id (defq msg (mail-mymail))) 0)
			(open-child (eval 'text (ui-find-id window (read-long ev_msg_action_source_id msg))) kn_call_open))
		(t (ui-event window msg))))
