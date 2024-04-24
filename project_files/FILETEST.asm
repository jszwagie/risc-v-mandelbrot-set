	.data
path:	.asciz "mandelbrot.bmp" # path to bmp file
pic:	.space 921738
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
	mv t0, a0 
	
	# reading file to buffer
	li a7, 63 
	li a2, 921738
	la a1, pic
	ecall
	
	# closing file
	li a7, 57
	mv a0, t0
	ecall
	
	# we will use fixed-point arythmetics
	# Values:
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# we will set comma on 11 place becouse our highest number will be 640
	# 01010000000.000000000000000000000 = 640
	
	# we remember about big endian
	
	# loading addres of buffer
	la s3, pic
	
	# skipping BMP header
	addi s3, s3, 138
	
	
	li s11, 400000 #counter
	
loop:
	# we starts with the last pixel
	# mock
	li s7, 80
	li s8, 80
	sb s7, (s3) # B
	addi s3, s3, 1
	sb s8, (s3) # G
	addi s3, s3, 1
	sb s7, (s3) # R
	addi s3, s3, 1
	addi s11, s11, -3
	blez s11, end
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
	li a2, 921738
	ecall
	
	# close file
	li a7, 57
	mv a0, t0
	ecall
	# exit program
	li a7, 10
	ecall

	
