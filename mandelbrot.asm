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

	
fn_map:
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
	
	# now we test only r
	
	li a0, -4194304 # -2.0
	li t6, 9830 # 0,0046875
	mul t3, t1, t6
	mulh t4, t1, t6
	slli t3, t3, 11
	srli t4, t4, 21
	add t5, t3, t4
	add a0, a0, t5
	
	ret
	
	
	
	
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
	
