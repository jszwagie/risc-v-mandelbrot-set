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
	# we will set comma on 11 place becouse our highest number will be 640
	# 01010000000.000000000000000000000 = 640
	
	# we remember about big endian
	
	# loading addres of buffer
	la s3, pic
	
	# skipping BMP header
	addi s3, s3, 138
	
	
	li s10, 221000 #counter
	li s9, 640
	li s8, 480
loop:
	# we starts with the last pixel
	mv a0, s9
	mv a1, s8
	li a2, 640
	li a3, 480
	call pixel_to_mandel
	call in_mandel_set
	#li a0, 50
	# n % 256
	mv s7, a0
	andi s7, s7, 0xff
	
	
	sb s7, (s3) # B
	addi s3, s3, 1
	
	
	sb s7, (s3) # G
	addi s3, s3, 1
	
	slli s7, s7, 2
	sb s7, (s3) # R
	addi s3, s3, 1
	
	# decrease counter
	addi s10, s10, -3
	blez s10, end
	
	# decrease x
	addi s9, s9, -1
	bgtz s9, loop
	
	# decrease y, set x
	li s9, 640
	addi s8, s8, -1
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
	
	
	
pixel_to_mandel: # nie dzia³a
	# Example of mapping function
	# def map_pixel_to_complex(x, y):
	#     width = 640
	#     height = 480
	#     min_real = -2.0
	#     max_real = 1.0
	#     min_imaginary = -1.5
	#     max_imaginary = 1.5
	#     range = max_real - min_real
	#     real_part = min_real + 3.0 * x / width
	#     range = max_imaginary - min_imaginary
	#     imaginary_part = min_imaginary + 3.0 * y / height
	
	#     return real_part, imaginary_part
	# so with our data
	# real_part = -2.0 + 3.0 * x / width
	# imaginary_part = -1.5 + 3.0 * y / height
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# we get arguments in a0-a7 registers	
	
	
	
	# initialize our constansts:
	# -2.0
	li t5, -2
	slli t5, t5, 21
	
	# -1.5
	li t6, -3
	slli t6, t6, 20
	
	# X - a0
	# Y - a1
	# Width - a2
	# Height - a3
	
	# making real part
	
	# x/width 
	# first shift x
	slli t1, a0, 21
	# divide
	div t1, t1, a2
	
	# * 3
	mv t0, t1
	slli t1, t1, 1
	add t1, t1, t0
	
	# - 2 and save to result
	add a0, t1, t5
	
	# making imaginary part
	
	# y/height
	# first shift y
	slli t1, a1, 21
	# divide
	div t1, t1, a3
	
	# * 3
	mv t0, t1
	slli t1, t1, 1
	add t1, t1, t0
	
	# - 1.5 and save to result
	add a1, t1, t6
	
	# returning from function values in a0 and a1
	ret

	
in_mandel_set:	
	# function takes 2 arguments a0,a1 - realpart, imaginartypart
	# we use s1, s2, s4, s5, s7, s11
	# s7, s11, s4 - are free to use
	# so s1, s2, s5 - should be saved
	
	# firse we save s1, s2, s5
	
	addi sp, sp, -12
	sw s1, 0(sp) # trzeba przerzucic do maina
	sw s2, 4(sp)
	sw s5, 8(sp)
	
	
	
	li s11, 55 #max iterations
	li s7, 0 # iterations
	li s1, 0 # z_real
	li s2, 0 # z_imaginary
	mv t1, a0 # c_real
	mv t2, a1 # c_imaginary
	li t3, 4 
	slli t3, t3, 21 # 4.0
loop_fn:
	# setting new z
	# zr*zr in s4
	mul t6, s1, s1
	mulh t5, s1, s1
	slli t5, t5, 11
	srli t6, t6, 21
	add s4, t6, t5
	
	# zi*zi in s5
	mul t6, s2, s2
	mulh t5, s2, s2
	slli t5, t5, 11
	srli t6, t6, 21
	add s5, t6, t5
	
	# -
	sub t0, s4, s5
	
	# + cr
	add t0, t0, t1
	
	# zr*zi
	mul t6, s2, s1
	mulh t5, s2, s1
	slli t5, t5, 11
	srli t6, t6, 21
	add t4, t6, t5
	# *2
	slli t4, t4, 1
	# + ci = new zi
	add s2, t4, t2
	
	#set zr
	mv s1, t0
	# increment iteration
	addi s7, s7, 1
	# first case
	bge s7, s11, end_fn
	
	# second case
	# zr*zr
	# zi*zi
	# +
	add t0, s4, s5
	
	ble t0, t3, loop_fn
	
	
	
end_fn:
	mv a0, s7
	
	# restoring registers
	lw s1, 0(sp)
	lw s2, 4(sp)
	lw s5, 8(sp)
	addi sp, sp, 12
	
	ret

		
