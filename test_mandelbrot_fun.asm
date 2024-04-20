	.data
path:	.asciz "mandelbrot.bmp" # path to bmp file
		
	.globl main
	.text

main:
	
	# we will use fixed-point arythmetics
	# Values:
	# MinReal = -2.0, MaxReal = 1.0, MinImaginary = -1.5, MaxImaginary = 1.5
	# we will set comma on 11 place becouse our highest number will be 640
	# 01010000000.000000000000000000000 = 640
	
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
	li a0, -1048576 # real part
	li a1, 0 # imaginary part
	call fn_mandel
	
	li a7, 1
	ecall
	b fend

	
fn_mandel:
	# function takes 2 arguments a0,a1 - realpart, imaginartypart
	# max iterations = 255
	li s11, 255 #max iterations
	li s0, 0 # iterations
	li s1, 0 # z_real
	li s2, 0 # z_imaginary
	mv t1, a0 # c_real
	mv t2, a1 # c_imaginary
	li t3, 8388608 # 4.0
	#while i<max iterations && zr*zr + zi*zi < 4
loop:
	# setting new z
	# zr*zr
	mul t6, s1, s1
	mulh t5, s1, s1
	slli t5, t5, 11
	srli t6, t6, 21
	add t0, t6, t5
	
	#- zi*zi
	mul t6, s2, s2
	mulh t5, s2, s2
	slli t5, t5, 11
	srli t6, t6, 21
	add t4, t6, t5
	sub t0, t0, t4
	
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
	bge s0, s11, end
	
	# second case
	# zr*zr
	mul t6, s1, s1
	mulh t5, s1, s1
	slli t5, t5, 11
	srli t6, t6, 21
	add t0, t6, t5
	
	# zi*zi
	mul t6, s2, s2
	mulh t5, s2, s2
	slli t5, t5, 11
	srli t6, t6, 21
	add t4, t6, t5
	# +
	add t0, t0, t4
	
	ble t0, t3, loop
	
	
	
end:
	mv a0, s0	
	ret
		

	
fend:

	# exit program
	li a7, 10
	ecall
	
