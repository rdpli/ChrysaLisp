%include 'inc/func.inc'
%include 'class/class_unordered_set.inc'
%include 'class/class_vector.inc'

def_func class/unordered_set/slice
	;inputs
	;r0 = unordered_set object
	;r1 = start element
	;r2 = end element
	;outputs
	;r0 = unordered_set object
	;r1 = unordered_set slice
	;trashes
	;all but r0, r4

	;save inputs
	set_src r0, r1, r2
	set_dst r9, r10, r11
	map_src_to_dst

	f_call unordered_set, create, {[r0 + unordered_set_key_callback], 1}, {r1}
	vp_cpy r11, r0
	vp_sub r10, r0
	vp_cpy r0, [r1 + unordered_set_length]
	f_jmp unordered_set, slice_impl, {r9, r1, $callback, r10, r11}

callback:
	;inputs
	;r0 = predicate data pointer
	;r1 = element iterator
	;outputs
	;r1 = 0 if break, else not

	vp_cpy [r0], r2
	f_call ref, ref, {[r1]}
	vp_push r0
	f_call unordered_set, get_bucket, {r2, r0}, {r0}
	vp_pop r1
	f_jmp vector, push_back, {r0, r1}

def_func_end
