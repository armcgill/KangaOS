.section ".text.boot"   // Ensure the linker puts this at the start of the kernel image

.global _start  // Execution starts here - tells kernel where the program begins

_start: 
    // Check processor ID is zero (executing on the main core), else hang
    mrs     x1, mpidr_el1   // writes the contents of mpidr_el1 into x1
    and     x1, x1, #3      // x1 = x1 & 0b11 (3)
    cbz     x1, 2f      //Comparing and if x1 = 0 then it is going to start executing instructions at 2 defined after this instruction. 
    // We're not on the main core, so hang in an infinite wait loop
1:  wfe     // Wait for event -> suspends execution
    b       1b      //jump to numeric label "1" defined before this instruction. 
2:  // We're on the main core! 

    // Set the stack to start below our code
    ldr    x1, =_start     // Loads address of _start in x1
    mov    sp, x1  // moves the addess in x1 to the stack pointer (R13)

    // Clean the BSS section 
    ldr     x1, =__bss_start    // Start address
    ldr     w2, =__bss_size     // Size of the section
3:  cbz     w2, 4f      // Quit loop if zero and go to section 4
    str     xzr, [x1], #8   // xzr = zero register; calculates the offset; subtracts 8 bits off of it. 
    sub     w2, w2, #1      // w2 = w2 - 1
    cbnz    w2, 3b      // Loop if non-zero

    // Jump to main() in C 
4:  bl      main
    // In case it returns... Stop master core
    b       1b
