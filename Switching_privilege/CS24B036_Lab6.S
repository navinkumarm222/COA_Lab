.section .data
	.align 3
	x: .dword 1
	y: .dword 2

.section .text
.global main
main:
	# Configure CSR registers (medeleg, mstatus, mepc, mtvec, stvec etc.)
	# Execute mret to initiate downward transition to User code
	
	# Setting up mepc to ucode
		la t0,ucode
		csrrw x0,mepc,t0
	
	# Setting up mtvec
		la t0,mtrap_handler
		csrrw x0,mtvec,t0
	
	# Setting up stvec
		la t0,strap_handler
		csrrw x0,stvec,t0 
	
	# set 1st,3rd,5th and 7th bit 		(0b 1010 1010)
		li t0,0xaa
		csrrs t1,mstatus,t0			
	
	# clear 11th and 12th bit		(0b 0001 1000 0000 0000)			
		li t0,0x1800
		csrrc t1,mstatus,t0
	
	# reading csr (mstatus)
		csrr t1,mstatus		
		
	# initialising a0
		mv a0,x0
		
	# setting up medeleg to jump to supervisor mode rather than machine mode
		li t0,256
		csrrs x0,medeleg,t0
	
	mret

.align 4
mtrap_handler:
	# Process traps originating from the strap_handler
	# Perform the multiplication operation
	# Flip a0 to 0
	# Set mepc back to strap_handler and execute mret
	
	# multiplication operation
		mul a1,a1,a2		
	
	# Flip a0
		li a0,0
		
	# set mepc to strap_handler
		csrr t0,stvec
		csrrw x0,mepc,t0
		
	# For testing purpose:
		csrr t6, mstatus
	mret

scode:
	# Execute sret to initiate transition to User mode after setting the CSRs
	
	# sepc <-- addr. of ucode1
		la t0,ucode1
		csrrw x0,sepc,t0
	
	# to go to User mode (inside ucode1):
		# clears 8th bit in sstatus (SPP)	(0b 0001 1000 0000 0000)
		li t0,256
		csrrc x0,sstatus,t0			
		
	sret

.align 4
strap_handler:
	# The Dispatcher
	# Check if a0 == 0 or a0 == 1
	# If a0 == 0: jump to scode (to setup S to U transition)
	# If a0 == 1: execute ecall to jump up to mtrap_handler
	
	# for testing purpose:
		csrr t6, sstatus
		
	beq a0,x0,scode
	ecall

ucode:
	# Note: Handle initial variable loading here if using a single User block
		la t0,x
		ld a1,0(t0)			# ???
		la t0,y
		ld a2,0(t0)			# ???
		
	ecall

ucode1:
	# Perform the addition operation
	# Flip a0 to 1
	# The ecall should invoke the supervisor’s trap handler
	
	# addition operation
		add a1,a1,a2		
	
	# Flip a0
		li a0,1
	
	ecall
