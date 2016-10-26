%include 'inc/func.inc'
%include 'class/class_vector.inc'

def_func class/vector/for_each
	;inputs
	;r0 = vector object
	;r1 = start index
	;r2 = end index
	;r3 = predicate function pointer
	;r5 = predicate data pointer
	;outputs
	;r0 = vector object
	;r1 = 0, else break iterator
	;trashes
	;all but r0, r4
		;callback predicate
		;inputs
		;r0 = predicate data pointer
		;r1 = element iterator
		;outputs
		;r1 = 0 if break, else not
		;trashes
		;all but r0, r4

	def_structure local
		ptr local_inst
		ptr local_predicate
		ptr local_predicate_data
		ptr local_next
		ptr local_end
	def_structure_end

	;save inputs
	vp_sub local_size, r4
	set_src r0, r3, r5
	set_dst [r4 + local_inst], [r4 + local_predicate], [r4 + local_predicate_data]
	map_src_to_dst

	;process elements
	vp_cpy [r0 + vector_array], r0
	vp_mul ptr_size, r1
	vp_mul ptr_size, r2
	vp_add r0, r1
	vp_add r0, r2
	vp_cpy r2, [r4 + local_end]
	loop_start
		vp_cpy r1, [r4 + local_next]
		breakif r1, ==, [r4 + local_end]
		vp_cpy [r4 + local_predicate_data], r0
		vp_call [r4 + local_predicate]
		breakif r1, ==, 0
		vp_cpy [r4 + local_next], r1
		vp_add ptr_size, r1
	loop_end

	;iterator of break point, else 0
	vp_cpy [r4 + local_next], r1
	vp_cpy [r4 + local_inst], r0
	if r1, ==, [r4 + local_end]
		vp_xor r1, r1
	endif
	vp_add local_size, r4
	vp_ret

def_func_end
