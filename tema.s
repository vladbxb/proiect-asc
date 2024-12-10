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
	lea arr, %esi
	xorl %eax, %eax
	movl $1024, %edx
	xorl %ecx, %ecx
	pushl %ecx
	pushl %edx
	pushl %eax
	pushl %esi
	#call zero_fill
	call fill_blocks
	addl $16, %esp
	#lea arr, %edi
	movl $1024, %eax
	pushl %eax
	#pushl %edi
	pushl %esi
	call print_array
	addl $8, %esp

	# citeste numarul de operatii
	pushl $operations
	pushl $scanfreadnum
	call scanf
	addl $8, %esp
	
	movl operations, %ecx
		
	#citeste codul operatiei
	pushl $opcode
	pushl $scanfreadnum
	call scanf
	addl $8, %esp
	
call_operation:
	movl $opcode, %eax
	cmp $1, %eax
	je ADD
	cmp $2, %eax
	je GET
	cmp $3, %eax
	je DELETE
	cmp $4, %eax
	je DEFRAGMENTATION
	cmp $5, %eax
	je CONCRETE

ADD:
	pushl $num_of_files
	pushl $scanfreadnum
	call scanf
	addl $8, %esp
	pushl %ebx
	lea arr, %esi
	xorl %ebx, %ebx
	movl num_of_files, %ecx
	ADD_loop:
		pushl $fd
		pushl $scanfreadnum
		call scanf
		addl $8, %esp
		pushl $size
		pushl $scanfreadnum
		call scanf
		addl $8, %esp
		movl size, %eax
		xorl %edx, %edx
		pushl %ecx
		movl $8, %ecx
		divl %ecx
		popl %ecx
		cmp $0, %edx
		jne decrease_offset
		pushl %eax
		addl %ebx, %eax
		pushl %ecx
		pushl %eax
		pushl %ebx
		pushl %esi
		call check_valid_space
		cmp $1, %eax
		je fill_space
		cmp $0, %eax
		je try_fill_space
		addl $8, %esp
		popl %eax
		popl %ecx
		incl %eax
		movl %eax, %ebx
		loop ADD_loop

	fill_space:
		movl fd, %eax
		pushl %eax
		pushl %ebx
		pushl %esi
		call fill_blocks
		addl $12, %esp
		jmp ADD_loop

	try_fill_space:
		pushl %ecx
		pushl %edi
		try_loop:
			cmp $1024, %eax
			jg ADD_invalid
			movb (%esi, %ebx, 1), %cl
			cmp $0, %cl
			jne change_bounds
			jmp try_done
		change_bounds:
			incl %ebx
			incl %eax
			jmp try_loop
			
			

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
