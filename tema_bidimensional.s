.data
	matr: .space 64
	ordine: .long 8
	line: .long 0
	line_stop: .long 0
	column: .long 0
	column_stop: .long 0
	fd: .long 0
	num_with_space: .asciz "%d "
	newline: .asciz "\n"
	
.text

zero_fill_matrix:
## void zero_fill_matrix(int *matr, int n)
## umple matricea pasata ca primul parametru de ordin n cu zero
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 12(%ebp), %eax
	movl 16(%ebp), %ecx
	pushl %eax
	movl %ecx, %eax
	xorl %edx, %edx
	imul %eax
	movl %eax, %edx
	popl %eax
	xorl %ecx, %ecx
	xorl %ebx, %ebx
	zero_fill_matrix_loop:
		cmp %edx, %ecx
		je zero_fill_matrix_return
		movb %bl, (%eax, %ecx, 1)
		incl %ecx

	zero_fill_matrix_return:
		popl %ebx
		popl %ebp
		ret

fill_blocks:
## void fill_blocks(int *matr, int n, int line, int start, int stop, int num)
## umple portiunea specificata de pe aceeasi linie 
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	movl 12(%ebp), ordine
	movl 16(%ebp), line
	movl 20(%ebp), column
	movl 24(%ebp), column_stop
	xorl %ebx, %ebx
	movl 28(%ebp), %ebx

	pushl %eax
	movl line, %eax
	movl ordine, %ecx
	xorl %edx, %edx
	imul %ecx
	addl column, %eax
	movl %eax, %ecx
	popl %eax

	pushl %eax
	pushl %ecx
	movl line, %eax
	movl ordine, %ecx
	xorl %edx, %edx
	imul %ecx
	addl column_stop, %eax
	movl %eax, %edx
	popl %ecx
	popl %eax
	
	fill_blocks_loop:
		cmp %ecx, %edx
		je fill_blocks_return
		movb %bl, (%eax, %ecx, 1)
		incl %ecx
		jmp fill_blocks_loop

	fill_blocks_return:
		popl %ebp
		ret

print_matrix:
## void print_matrix(int *matr, int n)
## afiseaza matricea de ordin n pe ecran, elementele fiind separate prin cate un spatiu
	pushl %ebp
	pushl %edi
	pushl %ebx
	movl %esp, %ebp
	movl 16(%ebp), %eax
	movl 20(%ebp), %ecx
	pushl %eax
	movl %ecx, %eax
	imul %eax
	movl %eax, %edx
	popl %eax
	xorl %edi, %edi
	xorl %ebx, %ebx
	print_matrix_loop:
		cmp %edi, %edx
		je print_matrix_return
		pushl %eax
		pushl %edx
		movl %edi, %eax
		xorl %edx, %edx
		divl %ecx
		cmp $0, %eax
		jne print_newline_first_cond
		print_matrix_loop_continue:
		popl %edx
		popl %eax
		movb (%eax, %edi, 1), %bl
		movzb %bl, %ebx
		pushl %eax
		pushl %ecx
		pushl %edx
		pushl %ebx
		pushl $num_with_space
		call printf
		popl %ebx
		popl %ebx
		popl %edx
		popl %ecx
		popl %eax
		incl %edi
		jmp print_matrix_loop

	print_newline_first_cond:
		cmp $0, %edx
		je print_newline_second_cond
		jmp print_matrix_loop_continue

	print_newline_second_cond:
		pushl %eax
		pushl %ecx
		pushl %edx
		pushl $newline
		call printf
		popl %edx
		popl %edx
		popl %ecx
		popl %eax
		jmp print_matrix_loop_continue

	print_matrix_return:
		popl %ebx
		popl %edi
		popl %ebp
		ret

.global main

main:
	lea matr, %edi
	movl $8, ordine
	pushl ordine
	pushl %edi
	call zero_fill_matrix
	popl %edi
	addl $4, %esp
	pushl $5
	pushl $7
	pushl $0
	pushl $0
	pushl %edi
	call fill_blocks
	popl %edi
	addl $16, %esp
	pushl ordine
	pushl %edi
	call print_matrix
	popl %edi
	addl $4, %esp
	jmp et_exit

et_exit:
	pushl $0
	call fflush
	popl %eax

	movl $1, %eax
	xorl %ebx, %ebx
	
	int $0x80
