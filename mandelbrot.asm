	.data
path:	.asciz "mandelbrot.bmp" # path to bmp file
pic:	.space 921738
		
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
	# we will set comma on 10 place becouse our highest number will be 640
	# 1010000000.0000000000000000000000 = 640
	
	
	
	# test reading and writing
	
	# loading addres of buffer
	la s0, pic
	
	# skipping BMP header
	addi s0, s0, 138
	
	# we must remember that the array is in big endian
	
	# test loop
	li s11, 921600 #counter
	li t6, 50 # color value to skip
	
loop:
	lb t0, (s0)
	beq t0, t6, next
	li t0, 50
	sb t0, (s0)
	addi s0, s0, 3 # next pixel 24-bit RGB
	addi s11, s11, -3
	blez s11, end
	b loop
next:
	addi s0, s0, 1
	addi s11, s11, -1
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
	
