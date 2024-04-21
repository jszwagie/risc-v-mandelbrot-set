	.data
path:	.asciz "fgh.bmp" # path to bmp file
	.align 2
pic:	.space 18
str:	.asciz " "

		
	.globl main
	.text

main:
	# opening file, file hanlde in a0
	li a7, 1024 
	li a1, 0
	la a0, path
	ecall
	# saving file handle
	mv t6, a0 
	
	# reading header and dib size to buffer
	li a7, 63 
	li a2, 18
	la a1, pic
	ecall
	
	
	
	# we will use fixed-point arythmetics
	# Values:
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# we will set comma on 11 place becouse our highest number will be 640
	# 01010000000.000000000000000000000 = 640
	
	# we remember about big endian
	
	# loading addres of buffer
#	la t0, pic
#	li s0, 18
#loop:
#	lb a0, (t0)
#	li a7, 1
#	ecall
#	
#	li a7, 4
#	la a0, str
#	ecall
	
#	addi t0, t0, 1
#	addi s0, s0, -1
#	bgtz s0, loop
	
	# getting size of file
	la t0, pic
	addi t0, t0, 2
	lhu a0, (t0)
	addi t0, t0, 2
	lhu t1, (t0)
	slli t1, t1, 16
	add a0, a0, t1
	mv s1, a0 # size of file here
	li a7, 1
	ecall
	
	li a7, 4
	la a0, str
	ecall
	
	#gettin size of dib header
	addi t0, t0, 10
	lhu a0, (t0)
	mv s0, a0 # size of dib header in s0
	li a7,1
	ecall
	
	li a7, 4
	la a0, str
	ecall
	
	# we allocate memory for whole file
	
	li a7, 9
	mv a0, s1
	ecall
	mv s2, a0 # s2- heap address
	
	# we read to heap
	# we starting after 18 bytes
	# read
	li a7, 63
	addi a2, s1, -18
	mv a1, s2
	mv a0, t6
	ecall
	
	mv t0, s2
	
	# we read witdh and height
	lw a0, (t0)
	mv s10, a0 # width here
	li a7, 1
	ecall
	
	li a7, 4
	la a0, str
	ecall
	
	addi t0, t0, 4
	lw a0, (t0)
	mv s8, a0 # height here
	li a7, 1
	ecall
	
	
	# closing file
	li a7, 57
	mv a0, t6
	ecall
	
	# we calculate padding
	# *3
	slli t0, s10, 1
	add t0, t0, s10
	andi t0, t0, 3 # rem 4
	li s9, 4
	sub s9, s9, t0
	andi s9, s9, 3 # rem 4
	# s9 - stored padding
	
	#going to the start of array
	
	mv t0, s2
	add t0, t0, s0
	addi t0, t0, -4
	lw a0, (t0)
	
	li a7, 1
	ecall
	
	addi s11, s1, -18
	sub s11, s11, s0 # lenght of array
	
	# s10- width s8 - height
	# s6 - t widrh, s5 - t height
	mv s6, s10
	mv s5, s8
	
	
	
loop:
	blez s5, end
	li a0, 0
	sb a0, (t0)
	addi s11, s11, -3
	addi t0, t0, 3
	addi s6, s6, -1
	bgtz s6, loop
	# go to end of row
	add t0, t0, s6
	# add padding
	add t0, t0, s9
	mv s6, s10
	addi s5, s5, -1
	b loop
	
	
end:
	# open file again
	li a7, 1024
	la a0, path
	li a1, 1
	ecall
	mv t0, a0
	
	# write buffer to file
	li a7, 64
	la a1, pic
	li a2, 18
	ecall
	
	# write heap
	# write buffer to file
	li a7, 64
	mv a1, s2
	addi a2, s1, -18
	mv a0, t0
	ecall
	
	# close file
	li a7, 57
	mv a0, t0
	ecall

	# exit program
	li a7, 10
	ecall

		
