# Task
The implementation must maintain a conditional
execution flow controlled by the value of register a0.
The execution begins at the main label in Machine mode. Initially, the program must shift directly
from Machine → User mode, and then trap up to Supervisor mode. From this point, the Supervisor
Trap Handler acts as a central dispatcher running in a continuous loop, while the Machine and User
modes act as mathematical workers. This iterative approach allows for the continuous observation
of privilege state modifications and Control and Status Register (CSR) behavior.
### (a) Initial Downward Transition (M → U)
The program begins execution in Machine mode. Before normal execution starts, the system
should transfer control to the User mode (ucode) where you will load two values, a1 and a2 , from
memory.
You will need to configure the mstatus, mtvec and the mepc register accordingly, and switch
control using the mret instruction.
### (b) Transition To Supervisor (U → S)
Move from ucode to the dispatcher (strap_handler). A system call should transfer control to a
Supervisor-level trap handler. You might have to configure the medeleg register.
### (c) The Dispatcher (Supervisor Trap Handler)
The Supervisor trap handler acts as a dispatcher that determines the next execution target.
A control value stored in register a0 determines the execution flow:
• Descend Condition (a0 == 0): Execution should proceed to a routine running in User mode
- the User Mode Worker (ucode1). This can be done by configuring the relevant control
registers.
• Ascend Condition (a0 == 1): The dispatcher must initiate an upward privilege escala-
tion and shift the control to the Machine mode Worker. This is achieved by intentionally
triggering a trap from within the Supervisor handler.

### (d) The Workers and Return Paths
Depending on the dispatch direction, the target privilege mode will perform a specific arithmetic
operation and return control to the dispatcher.
• User Mode Worker (Addition): While in User mode, perform the addition a1 = a1 + a2.
Then, flip a0 and issue an ecall to trap back to the dispatcher.
• Machine Mode Worker (Multiplication): Inside the mtrap_handler, perform the multi-
plication a1 = a1 * a2. Flip a0 and then issue an mret back to the dispatcher.

