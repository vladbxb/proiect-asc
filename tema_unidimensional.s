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

DEFRAGMENTATION_func:
## void DEFRAGMENTATION_func(*arr)
## defragmenteaza tot arrayul
	pushl %ebp
	pushl %edi
	pushl %esi
	pushl %ebx
	movl %esp, %ebp
	movl 20(%ebp), %eax
	xorl %edi, %edi
	xorl %esi, %esi
	xorl %ecx, %ecx
	xorl %edx, %edx
	xorl %ebx, %ebx
	DEFRAGMENTATION_loop:
		pushl $0
		pushl %edi
		pushl %eax
		call find_first_occurrence
		movl %eax, %edi
		popl %eax
		popl %edx
		popl %edx
		jmp DEFRAGMENTATION_find_esi

		DEFRAGMENTATION_found_empty_space:
		movb (%eax, %esi, 1), %dl
		movb %dl, (%eax, %edi, 1)
		incl %edi
		incl %esi
		cmp $1023, %esi
		je DEFRAGMENTATION_zero_fill
		jmp DEFRAGMENTATION_found_empty_space

	DEFRAGMENTATION_find_esi:
		pushl %edi
		pushl %eax
		call find_first_last_occurrence
		incl %eax
		movl %eax, %edx
		popl %eax
		popl %edi
		cmp $1024, %edx
		je DEFRAGMENTATION_return
		movl %edx, %esi
		jmp DEFRAGMENTATION_found_empty_space
		
	DEFRAGMENTATION_zero_fill:
		cmp $1024, %edi
		je DEFRAGMENTATION_reset_beginning
		xorl %ecx, %ecx
		movb %cl, (%eax, %edi, 1)
		incl %edi
		jmp DEFRAGMENTATION_zero_fill

	DEFRAGMENTATION_reset_beginning:
		xorl %edi, %edi
		jmp DEFRAGMENTATION_loop

	DEFRAGMENTATION_return:
		pushl $1
		pushl %eax
		call print_all_intervals
		popl %eax
		popl %ebx
		popl %ebx
		popl %esi
		popl %edi	
		popl %ebp
		ret

move_blocks:
	## int move_blocks(*arr, destination, start, end)
	## interschimba doua siruri de blocuri in memorie
	pushl %ebp
	pushl %ebx
	pushl %edi
	pushl %esi
	movl %esp, %ebp
	movl 20(%ebp), %eax
	movl 24(%ebp), %edi
	movl 28(%ebp), %esi
	movl 32(%ebp), %edx
	xorl %ecx, %ecx
	xorl %ebx, %ebx
	move_blocks_loop:
		cmp %esi, %edx
		je move_blocks_return
		movb (%eax, %edi, 1), %cl
		movb (%eax, %esi, 1), %bl
		movb %bl, (%eax, %edi, 1)
		movb %cl, (%eax, %esi, 1)
		incl %edi
		incl %esi
		jmp move_blocks_loop
	move_blocks_return:
		popl %esi
		popl %edi
		popl %ebx
		popl %ebp
		ret

find_first_occurrence:
	## int find_first_occurrence(*arr, start, num)
	## gaseste prima aparenta a numarului num in array incepand de la pozitia start
	## returneaza -1 daca nu gaseste numarul si pozitia numarului daca il gaseste
	## valoarea de return este in %eax
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 20(%ebp), %edx
	movl 16(%ebp), %ecx
	movl 12(%ebp), %eax
	xorl %ebx, %ebx
	first_occurrence_search:
		cmp $1024, %ecx
		je first_occurrence_not_found
		movb (%eax, %ecx, 1), %bl
		movzb %bl, %ebx
		cmp %edx, %ebx
		je first_occurrence_found
		incl %ecx
		jmp first_occurrence_search
		
	first_occurrence_not_found:
		movl $-1, %eax
		jmp find_first_occurrence_return

	first_occurrence_found:
		movl %ecx, %eax
		jmp find_first_occurrence_return

	find_first_occurrence_return:
		popl %ebx
		popl %ebp
		ret

find_first_last_occurrence:
	## int find_first_last_occurrence(*arr, start)
	## gaseste ultima aparenta din sirul de numere repetate in array formate din num care incepe de la pozitia start
	## returneaza strict pozitia numarului gasit (orice numar din array va avea o ultima aparenta, chiar formata si din ea insasi)
	## valoarea din return este in %eax
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 16(%ebp), %ecx
	movl 12(%ebp), %eax
	xorl %ebx, %ebx
	xorl %edx, %edx
	movb (%eax, %ecx, 1), %dl
	incl %ecx
	first_last_occurrence_search:
		cmp $1024, %ecx
		je found_first_last_occurrence
		movb (%eax, %ecx, 1), %bl
		cmp %bl, %dl
		jne found_first_last_occurrence
		incl %ecx
		jmp first_last_occurrence_search

	found_first_last_occurrence:
		decl %ecx
		movl %ecx, %eax
		jmp find_first_last_occurrence_return

	find_first_last_occurrence_return:
		popl %ebx
		popl %ebp
		ret
		
		

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

print_all_intervals:
	## void print_all_intervals(*arr, bool flag)
	## afiseaza pe ecran toate blocurile de date stocate ca intervale
	pushl %ebp
	pushl %ebx
	movl %esp, %ebp
	movl 12(%ebp), %eax
	xorl %ecx, %ecx
	xorl %ebx, %ebx
	print_all_intervals_loop:
		cmp $1024, %ecx
		je print_all_intervals_return
		movb (%eax, %ecx, 1), %bl
		cmp $0, %bl
		jne print_found_interval
		incl %ecx
		jmp print_all_intervals_loop
	

	print_found_interval:
		movl %ebx, fd
		pushl %ecx
		pushl %eax
		call find_first_last_occurrence
		movl %eax, %edx
		popl %eax
		popl %ecx
		movl 16(%ebp), %ebx
		cmp $1, %ebx
		je print_with_fd
		jmp print_without_fd
		print_found_interval_continue:
		movl %edx, %ecx
		incl %ecx
		jmp print_all_intervals_loop

	print_all_intervals_return:
		popl %ebx
		popl %ebp
		ret
	
	print_without_fd:
		pushl %eax
		pushl %edx
		pushl %ecx
		pushl $interval
		call printf
		popl %ecx
		popl %ecx
		popl %edx
		popl %eax
		jmp print_found_interval_continue

	print_with_fd:
		pushl %eax
		pushl %edx
		pushl %ecx
		pushl fd
		pushl $fd_si_interval
		call printf
		popl %ecx
		popl %ecx
		popl %ecx
		popl %edx
		popl %eax
		jmp print_found_interval_continue

GET_func:
	## void GET_func(int fd, bool flag)
	## furnizeaza in beg si end variabile globale capatul de la inceput si de la sfarsitul intervalului gasit
	## prin pasarea parametrului $1 afisam in plus si intervalul pe ecran FARA file descriptor
	pushl %ebp
	movl %esp, %ebp
	pushl %ecx
	GET_after_read:
	popl %ecx

	movl 8(%ebp), %eax
	pushl %ecx
	pushl %eax
	pushl $0
	pushl %edi
	call find_first_occurrence
	popl %ecx
	popl %ecx
	popl %ecx
	popl %ecx
	cmp $-1, %eax
	je GET_invalid_interval
	movl %eax, beg
	
	pushl %ecx
	pushl %eax
	pushl %edi
	call find_first_last_occurrence
	popl %ecx
	popl %ecx
	popl %ecx

	movl %eax, end
	jmp GET_return_interval
	# pushl %ecx
	# pushl %ebx
	# xorl %ecx, %ecx
	# xorl %edx, %edx
	# xorl %eax, %eax
	# movl $0, beg
	# movl $0, end
	# GET_loop:
	# 	cmp $1024, %ecx
	# 	je GET_not_found
	# 	movb (%edi, %ecx, 1), %al
	# 	cmp fd, %al
	# 	je GET_found_descriptor
	# 	movl beg, %ebx
	# 	cmp $0, %ebx
	# 	jne GET_found_last
	# 	jmp GET_loop
	# 	
	# GET_found_descriptor:
	# 	cmp $0, %edx
	# 	je GET_found_first
	# 	GET_found_descriptor_continue:
	# 		incl %ecx
	# 		jmp GET_loop

	# GET_not_found:
	# 	movl beg, %ebx
	# 	cmp $0, %ebx
	# 	jne GET_found_last
	# 	movl $0, beg
	# 	movl $0, end
	# 	jmp GET_return_interval

	# GET_found_first:
	# 	movl $1, %edx
	# 	movl %ecx, beg
	# 	jmp GET_found_descriptor_continue

	# GET_found_last:
	# 	decl %ecx
	# 	movl %ecx, end
	# 	jmp GET_return_interval
	GET_invalid_interval:
		movl $0, beg
		movl $0, end
		jmp GET_return_interval

	GET_return_interval:
		movl 12(%ebp), %eax
		cmp $1, %eax
		je GET_print_interval
		# popl %ebx
		# popl %ecx
		jmp GET_return
		

	GET_print_interval:
		pushl end
		pushl beg
		pushl $interval
		call printf
		popl %eax
		popl %eax
		popl %eax
		jmp GET_return

	GET_return:
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
	
	operations_loop:
		movl operations, %ecx
		#citeste codul operatiei
		cmp $0, %ecx
		je et_exit
		pushl %ecx
		pushl $opcode
		pushl $scanfreadnum
		call scanf
		popl %ecx
		popl %ecx
		popl %ecx
		decl %ecx
		movl %ecx, operations
		jmp call_operation
	
call_operation:
	#popl %ecx
	movl opcode, %eax
	cmp $1, %eax
	je ADD
	#jmp possible_error
	cmp $2, %eax
	je GET
	cmp $3, %eax
	je DELETE
	cmp $4, %eax
	je DEFRAGMENTATION
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
		popl %ebx
		cmp $2, %eax
		jl ADD_invalid_input
		cmp $0, %edx
		jne increment_block
		found_block_amount:
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
		
			#pushl %ecx
			#pushl %edx
			#pushl %eax
			#pushl fd
			#pushl $fd_si_interval
			#call printf
			#popl %ecx
			#popl %ecx
			#popl %ecx
			#popl %ecx
			#popl %ecx
	
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
			pushl $1
			pushl %edi
			call print_all_intervals
			popl %edi
			popl %ecx
			popl %ecx
			jmp operations_loop
		
		increment_block:
			incl %eax
			jmp found_block_amount

		ADD_invalid_input:
			decl %ecx
			jmp operations_loop
GET:
	pushl $fd
	pushl $scanfreadnum
	call scanf	
	popl %eax
	popl %eax
	pushl %ecx
	pushl $1
	pushl fd
	call GET_func
	popl %eax
	popl %eax
	popl %ecx
	jmp operations_loop
		
DELETE:
	pushl $fd
	pushl $scanfreadnum
	call scanf
	DELETE_after_read:
	addl $8, %esp
	pushl %ecx
	pushl $0
	pushl fd
	call GET_func
	popl %eax
	popl %eax
	popl %ecx
	pushl %ecx
	pushl $0
	pushl end
	pushl beg
	pushl %edi
	call fill_blocks
	addl $16, %esp
	addl $4, %esp
	popl %ecx
	pushl %ecx
	pushl $1
	pushl %edi
	call print_all_intervals
	popl %edi
	popl %ecx
	popl %ecx
	jmp operations_loop

DEFRAGMENTATION:
	pushl %ecx
	pushl %edi
	call DEFRAGMENTATION_func
	popl %edi
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
