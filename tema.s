.data
	arr: .space 1024
	arrsize: .long 1024
	operations: .long 0
	opcode: .long 0
	num_of_files: .long 0
	fd: .long 0
	beg: .long 0
	end: .long 0
	size: .long 0
	# x: .long 1
	spacedelimfmt: .asciz "%d "
	scanfreadnum: .asciz "%d"
	newline: .asciz "\n"
	exit_error: .asciz "programul nu a iesit in siguranta :(\n"
	fd_si_interval: .asciz "%d: (%d, %d)\n"
	interval: .asciz "(%d, %d)\n"

.text
# zero_fill:
# 	pushl %ebp
# 	movl %esp, %ebp
# 	xorl %ecx, %ecx
# 	movl 12(%ebp), %edx
# 	movl 8(%ebp), %eax
# 	zfill_loop:
# 		cmp %edx, %ecx
# 		je zfill_done
# 		movb $0, (%eax, %ecx, 1)
# 		incl %ecx
# 		jmp zfill_loop
# 	zfill_done:
# 		popl %ebp
# 		ret

check_valid_space:
	## bool check_valid_space(*arr, start, stop)
	## valoarea de return este in %eax
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 20(%ebp), %edx
	movl 16(%ebp), %ebx
	movl 12(%ebp), %eax
	valid_space_loop:
		movb (%eax, %ebx, 1), %cl
		cmp $0, %cl
		jne invalid_space
		cmp %ebx, %edx
		je valid_space
		incl %ebx
		jmp valid_space_loop
	invalid_space:
		movl $0, %eax
		jmp valid_space_loop_done
	valid_space:
		movl $1, %eax
		jmp valid_space_loop_done
	valid_space_loop_done:
		popl %ebx
		popl %ebp
		ret
	
search_valid_space:
	## int search_valid_space(*arr, size)
	## returneaza pozitiile start=%eax si end=%edx unde se pot modifica blocurile in siguranta
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 16(%ebp), %edx
	movl 12(%ebp), %eax
	movl $0, beg
	decl %edx
	#subl $1, %edx
	movl %edx, end
	check_condition:
		pushl %ecx
		pushl end
		pushl beg
		pushl %eax
		call check_valid_space
		movl %eax, %ebx
		popl %eax
		popl %ecx
		popl %ecx
		popl %ecx	
		cmp $1, %ebx
		je found_valid_space
		cmp $0, %ebx
		je keep_searching

	found_valid_space:
		movl beg, %eax
		movl end, %edx
		jmp return_interval
	
	keep_searching:
		movl end, %ebx
		cmp $1024, %ebx
		je valid_space_not_found
		movl beg, %ebx
		incl %ebx
		movl %ebx, beg
		movl end, %ebx
		incl %ebx
		movl %ebx, end
		jmp check_condition

	valid_space_not_found:
		movl $0, %eax
		movl $0, %edx
		jmp return_interval
		

	return_interval:
		popl %ebx
		popl %ebp
		ret


fill_blocks:
	## void fill_blocks(*arr, start, stop, num)
	## umple in portiunea specificata intre pozitiile start si stop (interval inchis) tabloul unidimensional pasat ca parametru cu numarul num
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 24(%ebp), %ebx
	movl 20(%ebp), %edx
	movl 16(%ebp), %ecx  
	movl 12(%ebp), %eax
	incl %edx
	fill_loop:
		cmp %edx, %ecx
		je fill_done
		movb %bl, (%eax, %ecx, 1)
		incl %ecx
		jmp fill_loop
	fill_done:
		popl %ebx
		popl %ebp
		ret
		


print_array:
	## print_array(int *arr, int amount)
	## afiseaza pe ecran primele "amount" numere dintr-un array cu spatiu intre ele incepand de la primul
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 16(%ebp), %edx
	movl 12(%ebp), %eax
	xorl %ecx, %ecx
	print_loop:
		cmp %edx, %ecx
		je print_done
		movb (%eax, %ecx, 1), %bl
		movzb %bl, %ebx
		pushl %eax
		pushl %edx
		pushl %ecx
		pushl %ebx
		pushl $spacedelimfmt
		call printf
		popl %ebx
		popl %ebx
		popl %ecx
		popl %edx
		popl %eax
		incl %ecx
		jmp print_loop
	print_done:
		pushl $newline
		call printf
		popl %ebx
	popl %ebx
	popl %ebp
	ret

.global main

main:
	## umple arrayul "arr" de zero
	lea arr, %edi
	xorl %eax, %eax
	movl $1024, %edx
	xorl %ecx, %ecx
	pushl %ecx
	pushl %edx
	pushl %eax
	pushl %edi
	call fill_blocks
	popl %edi
	popl %eax
	popl %edx
	popl %ecx

	# pushl $69
	# pushl $15
	# pushl $0
	# pushl %edi
	# call fill_blocks
	# addl $16, %esp
	# 
	# pushl $1024
	# pushl %edi
	# call print_array
	# addl $8, %esp

	# jmp et_exit

	# citeste numarul de operatii
	pushl $operations
	pushl $scanfreadnum
	call scanf
	popl %ecx
	popl %ecx
	
	movl operations, %ecx
	operations_loop:
		#citeste codul operatiei
		pushl %ecx
		pushl $opcode
		pushl $scanfreadnum
		call scanf
		popl %ecx
		popl %ecx
		popl %ecx
		jmp call_operation
		end_operation:
			loop operations_loop
	
call_operation:
	movl opcode, %eax
	cmp $1, %eax
	je ADD
	#jmp possible_error
	cmp $2, %eax
	je GET
	#cmp $3, %eax
	#je DELETE
	#cmp $4, %eax
	#je DEFRAGMENTATION
	#cmp $5, %eax
	#je CONCRETE

ADD:
	## salvez contorul %ecx de la operations_loop pentru ca scanf il va strica fiind caller-saved
	## apoi citesc numarul de fisiere pe care il adaug in tablou
	## PASTREZ %ECX IN STIVA PENTRU CA IL VOI FOLOSI PENTRU LOOPUL ULTERIOR (ca sa salvez %ecx ul precedent de la operations_loop)
	pushl %ecx
	pushl $num_of_files
	pushl $scanfreadnum
	call scanf
	popl %ecx
	popl %ecx
	movl num_of_files, %ecx
	input_file_loop:
		## citeste file descriptor
		pushl %ecx
		pushl $fd
		pushl $scanfreadnum
		call scanf
		popl %ecx
		popl %ecx
		popl %ecx
		## citeste marimea fisierului
		pushl %ecx
		pushl $size
		pushl $scanfreadnum
		call scanf
		popl %ecx
		popl %ecx
		popl %ecx
		xorl %edx, %edx
		pushl %ebx
		movl size, %eax
		movl $8, %ebx
		divl %ebx
		cmp $0, %edx
		jne increment_block
		found_block_amount:
			popl %ebx
			movl %eax, size
			pushl %ecx
			pushl size
			pushl %edi
			call search_valid_space
			popl %ecx
			popl %ecx
			popl %ecx
			pushl %ecx
			pushl fd
			pushl %edx
			pushl %eax
			pushl %edi
			call fill_blocks
			#addl $16, %esp
			popl %ebx
			popl %eax
			popl %ebx
			popl %ebx
			popl %ecx
			
			decl %edx
		
			pushl %ecx
			pushl %edx
			pushl %eax
			pushl fd
			pushl $fd_si_interval
			call printf
			popl %ecx
			popl %ecx
			popl %ecx
			popl %ecx
			popl %ecx
	
# 			movl $1024, %eax
# 			pushl %eax
# 			pushl %edi
# 			call print_array
# 			popl %edi
# 			popl %eax
# 

			#loop input_file_loop
			#popl %ecx
			loop input_file_loop
			jmp operations_loop
		
		increment_block:
			incl %eax
			jmp found_block_amount

GET:
	pushl %ecx
	pushl $fd
	pushl $scanfreadnum
	call scanf
	CONTINUE_GET:
	popl %ecx
	popl %ecx
	popl %ecx	
	pushl %ecx
	pushl %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
	xorl %eax, %eax
	movl $0, beg
	movl $0, end
	GET_loop:
		cmp $1024, %ecx
		je GET_not_found
		movb (%edi, %ecx, 1), %al
		cmp fd, %al
		je GET_found_descriptor
		movl beg, %ebx
		cmp $0, %ebx
		jne GET_found_last
		jmp GET_loop
		
	GET_found_descriptor:
		cmp $0, %edx
		je GET_found_first
		GET_found_descriptor_continue:
			incl %ecx
			jmp GET_loop

	GET_not_found:
		movl beg, %ebx
		cmp $0, %ebx
		jne GET_found_last
		movl $0, beg
		movl $0, end
		jmp GET_return_interval

	GET_found_first:
		movl $1, %edx
		movl %ecx, beg
		jmp GET_found_descriptor_continue

	GET_found_last:
		decl %ecx
		movl %ecx, end
		jmp GET_return_interval

	GET_return_interval:
		pushl end
		pushl beg
		pushl $interval
		call printf
		addl $12, %esp
		popl %ebx
		popl %ecx
		jmp operations_loop
		
possible_error:
	pushl $exit_error
	call printf
	popl %ecx
	jmp et_exit

et_exit:
	#pushl $newline
	#call printf
	#popl %eax
	pushl $0
	call fflush
	popl %eax
	
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80
