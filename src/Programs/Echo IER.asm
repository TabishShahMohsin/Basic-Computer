/ =================================================================
/ Program: Interrupt-Driven Character Echo (No-NOP Edition)
/ Description: Main program runs in an isolated loop. 
/              Safe from Return Address Alignment traps.
/ =================================================================

ORG 0
RES_ADDR, HEX 0      / Location 0: Return address save slot
          BUN ISR    / Location 1: Jump to ISR

ORG 10               / Main Program starts at address 0x010
START,
          ION        / Enable the interrupt system (IEN <- 1)

MAIN_LP,
          LDA C_0    / Supported instruction acting as an idle pad
          BUN MAIN_LP/ Spin infinitely awaiting keyboard flags

/ =================================================================
/ INTERRUPT SERVICE ROUTINE (ISR)
/ =================================================================
ISR,
          INP        / AC(0-7) <- INPR (Automatically clears FGI)
          
W_OUT,    SKO        / Poll Output Flag (FGO)
          BUN W_OUT  / Wait if transmitter is busy
          
          OUT        / Send the character cleanly to the TTY monitor
          
          ION        / Re-arm the interrupt system
          BUN RES_ADDR I / Indirect return home safely
          
/ --- Storage & Constants ---
C_0,      DEC 0
END