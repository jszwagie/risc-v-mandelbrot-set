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
	lw s5, (s3) # height here
	
	
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
	
	# s10- width s5 - height
	# s6 - t widrh,
	mv s6, s10
	
	# register left: t0-t6, s7, s11, maybe s4
	
loop:
	li a0, 640
	li a1, 0
	li a2, 640
	li a3, 480
	call pixel_to_mandel
	
	li a7, 1
	ecall
	
	mv a0, a1
	ecall
#	blez s5, end
#	li a0, 0
#	sb a0, (s3)
#	sb a0, 1(s3)
#	sb a0, 2(s3) # tu do sprawdzenia warunki
#	addi s3, s3, 3
#	addi s6, s6, -1
#	bgtz s6, loop
#	# go to end of row
#	add s3, s3, s6
#	# add padding
#	add s3, s3, s9
#	mv s6, s10
#	addi s5, s5, -1
#	b loop
	
	
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
	
pixel_to_mandel:
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
	srli t1, t1, 1
	add t1, t1, t0
	
	# - 1.5 and save to result
	add a1, t1, t6
	
	# returning from function values in a0 and a1
	ret
		
