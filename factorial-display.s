.global _start

__default_stacksize=1024
_start:
	# startup sequence: nothing
	movia sp, STACK				# give stack initial value
	
	# prologue of read: nothing
	call read					# read val from switches
	# epilogue of read: r2 = val
	
	# prologue of fact
	mov r4, r2					# copy val to n parameter
	call fact
	# epilogue of fact: r2 = res
	
	# prologue of printhex
	mov r4, r2					# copy res to val parameter
	call printHex
	# epilogue of printhex: nothing
	
	movi r2, 0					# return 0;
	
	# cleanup sequence: nothing
	ret
	
read:
	# startup seq
	subi sp, sp, 4				# alloc space on stack
	stw r16, 0(sp)				# store r16
	
	movia r16, 0x10000040		# address of switches
	ldwio r2, 0(r16)			# return value from switches
	
	# cleanup seq
	ldw r16, 0(sp)				# restore r16
	addi sp, sp, 4				# dealloc space on stack
	ret
		
fact:
	# startup seq
	subi sp, sp, 8				# alloc space on stack
	stw r4, 0(sp)				# store n on stack
	stw ra, 4(sp)				# store return address
	
	bne r4, r0, else			# else condition: if n != 0	
	movi r2, 1					# if 0, return 1
	# cleanup seq 1
	ldw r4, 0(sp)				# restore n
	ldw ra, 4(sp)				# restore return address
	addi sp, sp, 8				# dealloc space on stack
	ret
	
	else:
		# prologue for fact
		subi r4, r4, 1			# param for recursive call: n-1
		call fact
		# epilogue: none
		
		# cleanup seq 2
		ldw r4, 0(sp)			# restore n
		ldw ra, 4(sp)			# restore return address
		addi sp, sp, 8			# dealloc space on stack
		mul r2, r2, r4			# return n * ret val from recursive call
		ret

printHex:
	#startup seq
	subi sp, sp, 16				# alloc space on stack
	stw r16, 0(sp)				# store r16
	stw r17, 4(sp)				# store r17
	stw r18, 8(sp)				# store r18
	stw ra, 12(sp)				# store return address
	
	mov r17, r4					# val is in r17
	movi r16, 0					# r16 = 0 (going to OR with it)
	
	andi r4, r17, 0x0f 			# put last four bits into r4
	call lookup					# look up last 4 bits
	or r16, r2, r16				# put into r16
	srli r17, r17, 4			# shift input right by 4 bits
	# repeat
	
	# prologue for lookup
	andi r4, r17, 0x0f			# last 4 bits of shifted input
	call lookup
	# epilogue: nothing
	slli r2, r2, 8				# shift value from lookup left
	or r16, r2, r16				# add into r16
	srli r17, r17, 4			# shift input
	# repeat
	
	andi r4, r17, 0x0f			# last 4 bits of shifted input
	call lookup
	slli r2, r2, 16				# shift val from lookup left
	or r16, r2, r16				# add into r16
	srli r17, r17, 4
	# repeat
	
	andi r4, r17, 0x0f			# last 4 bits of shifted input
	call lookup
	slli r2, r2, 24				# shift val from lookup left
	or r16, r2, r16				# add bits into r16
	srli r17, r17, 4

	movia r18, 0x10000020		# address of SSD
	stwio r16, 0(r18)			# store to ssd
	
	#cleanup seq
	addi sp, sp, 16				# dealloc space on stack
	ldw r16, 0(sp)				# restore r16
	ldw r17, 4(sp)				# restore r17
	ldw r18, 8(sp)				# restore r18
	ldw ra, 12(sp)				# restore return address
	ret
	
lookup:
	# startup seq
	subi sp, sp, 8				# alloc space on stack
	stw r16, 0(sp)				# store r16
	stw r17, 4(sp)				# store r17
	
	movia r16, lut				# address of lut
	muli  r17, r4, 4			# r17 = i * 4
	add   r17, r16, r17			# r17 = address = i * 4 + &lut
	ldw   r2, 0(r17)			# return value from lut
	
	# cleanup seq
	ldw r16, 0(sp)				# restore r16
	ldw r17, 4(sp)				# restore r17
	addi sp, sp, 8
	ret
	
.data
	lut:
		.word 0x0000003F		#lut[0]
		.word 0x00000006		#lut[1]
		.word 0x0000005B		#lut[2]
		.word 0x0000004F		#lut[3]
		.word 0x00000066		#lut[4]
		.word 0x0000006D		#lut[5]
		.word 0x0000007D		#lut[6]
		.word 0x00000007		#lut[7]
		.word 0x000000ff		#lut[8]
		.word 0x0000006F		#lut[9]
		.word 0x00000077		#lut[a]
		.word 0x0000007C		#lut[b]
		.word 0x00000058		#lut[c]
		.word 0x0000005E		#lut[d]
		.word 0x00000079		#lut[e]
		.word 0x00000071		#lut[f]

.skip __default_stacksize
STACK:
.end