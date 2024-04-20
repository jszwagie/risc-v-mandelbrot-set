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
	
	
	li s10, 921738 #counter
	li s9, 640
	li s8, 480
loop:
	# we starts with the last pixel
	mv a0, s9
	mv a1, s8
	slli a0, a0, 21
	slli a1, a1, 21
	call pixel_to_mandel
	
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
	
	
	
pixel_to_mandel:
	# Example of mapping function in python
	# def map_pixel_to_complex(x, y):
	#     width = 640
	#     height = 480
	#     min_real = -2.0
	#     max_real = 1.0
	#     min_imaginary = -1.5
	#     max_imaginary = 1.5
	#     range = max_real - min_real
	#     real_part = min_real + 3.0 * x / 640
	#     range = max_imaginary - min_imaginary
	#     imaginary_part = -(min_imaginary + 3.0 * y / 480)
	
	#     return real_part, imaginary_part
	# so with our data
	# real_part = -2.0 + x*0,0046875
	# imaginary_part = -(-1.5 + y*0,00625) = 1.5 - y*0,00625
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# width = 640, height = 480 
	# we get arguments in a0-a7 registers	
	# real_part = -2.0 + x*0,0046875
	# 0,0046875 = 0.00000001001100110011001100110011(in NKB) = 00000000000.000000010011001100110 (in our fixed point U2) = 9830 in register
	# -2.0 = 11111111110.000000000000000000000 (in our fixed point U2) = -4194304 in register
	# imaginary_part = 1.5 - y*0,00625
	# 0,00625 = 0.00000001100110011001100110011001 (in NKB) = 00000000000.000000011001100110011 (in our fixed point U2) = 13107 in register
	# 1.5 = 00000000001.100000000000000000000 (in our fixed point U2) = 3145728 in register
	
	
	# get X
	mv t1, a0
	#get Y
	mv t2, a1
	
	# making real part 
	
	li a0, -4194304 # -2.0
	li t6, 9830 # 0,0046875
	mul t3, t1, t6
	mulh t4, t1, t6
	slli t4, t4, 11
	srli t3, t3, 21
	add t5, t3, t4
	add a0, a0, t5
	
	#making imaginary part
	
	li a1, 3145728 # 1.5
	li t6, 13107 # 0,00625
	mul t3, t2, t6
	mulh t4, t2, t6
	slli t4, t4, 11
	srli t3, t3, 21
	add t5, t3, t4
	sub a1, a1, t5
	
	# returning from function values in a0 and a1
	
	# function takes 2 arguments a0,a1 - realpart, imaginartypart
	# max iterations = 255
	li s11, 55 #max iterations
	li s0, 0 # iterations
	li s1, 0 # z_real
	li s2, 0 # z_imaginary
	mv t1, a0 # c_real
	mv t2, a1 # c_imaginary
	li t3, 8388608 # 4.0
	#while i<max iterations && zr*zr + zi*zi < 4
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
	addi s0, s0, 1
	# first case
	bge s0, s11, end_fn
	
	# second case
	# zr*zr
	# zi*zi
	# +
	add t0, s4, s5
	
	ble t0, t3, loop_fn
	
	
	
end_fn:
	mv a0, s0	
	ret
	
mock_m:
	li a0, 50
	ret
		
