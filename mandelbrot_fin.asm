	.data
path:	.asciz "test_3.bmp" # path to bmp file
	.align 2
header:	.space 18
str:	.asciz " "

		
	.globl main
	.text

main:
	# temporary: a0-a7, s3-t6, ra
	# saved: s0-s11, sp 
	
	# opening file, file hanlde in a0
	li a7, 1024 
	li a1, 0
	la a0, path
	ecall
	# saving file handle
	mv s0, a0 
	
	# reading header and dib size to buffer
	li a7, 63 
	li a2, 18
	la a1, header
	ecall
	
	
	
	# we will use fixed-point arythmetics
	# Values:
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# we will set comma on 11 place becouse our highest number will be 640
	# 01010000000.000000000000000000000 = 640
	
	# we remember about big endian
	
	# getting size of file
	la s3, header
	addi s3, s3, 2
	lhu s1, (s3)
	addi s3, s3, 2
	lhu t0, (s3)
	slli t0, t0, 16
	add s1, s1, t0
	# size of file in s1
		
	#getting size of dib header
	addi s3, s3, 10
	lhu s4, (s3)
	# size of dib header in s4
	
	# we allocate memory for whole file (-18 because we read heder previously)
	li a7, 9
	mv a0, s1
	addi a0, s1, -18
	ecall
	mv s2, a0 # s2- heap address
	
	# we read file and write it to heap
	# we starting after 18 bytes
	# read
	li a7, 63
	addi a2, s1, -18
	mv a1, s2
	mv a0, s0
	ecall
	
	mv s3, s2
	
	# we read witdh and height
	lw s10, (s3)
	# width here
	
	addi s3, s3, 4
	lw a0, (s3)
	mv s8, a0 # height here
	li a7, 1
	ecall
	
	
	# closing file
	li a7, 57
	mv a0, s0
	ecall
	
	# we calculate padding
	# *3
	slli s3, s10, 1
	add s3, s3, s10
	andi s3, s3, 3 # rem 4
	li s9, 4
	sub s9, s9, s3
	andi s9, s9, 3 # rem 4
	# s9 - stored padding
	
	#going to the start of array
	
	mv s3, s2
	add s3, s3, s4
	addi s3, s3, -4
	lw a0, (s3)
	
	li a7, 1
	ecall
	
	addi s11, s1, -18
	sub s11, s11, s4 # lenght of array
	
	# s10- width s8 - height
	# s6 - t widrh, s5 - t height
	mv s6, s10
	mv s5, s8
	
	
	
loop:
	blez s5, end
	li a0, 0
	sb a0, (s3)
	sb a0, 1(s3)
	sb a0, 2(s3)
	addi s11, s11, -3
	addi s3, s3, 3
	addi s6, s6, -1
	bgtz s6, loop
	# go to end of row
	add s3, s3, s6
	# add padding
	add s3, s3, s9
	mv s6, s10
	addi s5, s5, -1
	b loop
	
	
end:
	# open file again
	li a7, 1024
	la a0, path
	li a1, 1
	ecall
	mv s3, a0
	
	# write buffer to file
	li a7, 64
	la a1, header
	li a2, 18
	ecall
	
	# write heap
	# write buffer to file
	li a7, 64
	mv a1, s2
	addi a2, s1, -18
	mv a0, s3
	ecall
	
	# close file
	li a7, 57
	mv a0, s3
	ecall

	# exit program
	li a7, 10
	ecall

		
