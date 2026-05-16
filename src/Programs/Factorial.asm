/ =================================================================
/ Continuous Base-10 Factorial Program with TTY Clear Function
/ Input: Type a decimal number (e.g., '4' Enter) -> Prints '24'
/ Next Input: Type another number (e.g., '8' Enter) -> Clears screen, prints '40320'
/ Exit Condition: Type '.' at any time to halt the simulation execution
/ Maximum Safe Input: 8 (9! overflows 16-bit registers)
/ =================================================================

ORG 0
START,  LDA C_0
        STA NUM       / Reset accumulated input number back to 0 for a fresh cycle

/ --- Step 1: Character Input & Exit Character Parsing Loop ---
IN_LP,  SKI           / Poll Input Flag (FGI) until a key is pressed
        BUN IN_LP
        INP           / AC(0-7) <- INPR (High bits are hardware grounded to 0)
        STA CHAR      / Save pristine ASCII code

        / Check if the Period Key was pressed ('.' = 46) to terminate program
        ADD M_46      / AC = CHAR - 46
        SZA           / If AC is 0 (it was '.'), skip jump to exit program
        BUN CHK_LF    / Not '.', continue checking for Enter keys
        BUN HALT_PROG / It was '.'! Exit the loop and halt the system
        
CHK_LF, LDA CHAR
        ADD M_10      / Check if Enter Key was a Line Feed (LF = 10)
        SZA
        BUN NOT_LF
        BUN EXP_START / It was LF! Proceed to factorial calculation
        
NOT_LF, LDA CHAR
        ADD M_13      / Check if Enter Key was a Carriage Return (CR = 13)
        SZA
        BUN PROCESS   / Not Enter -> Validated as a normal numeric digit character
        BUN EXP_START / It was CR! Proceed to factorial calculation

PROCESS,
        LDA CHAR
        ADD M_48      / Convert ASCII '0'-'9' to raw int 0-9
        STA DIGIT

        / Multiply current NUM by 10 using purely robust ADD instructions
        LDA NUM
        ADD NUM       / AC = 2 * NUM
        STA TMP       / Save (2 * NUM)
        ADD TMP       / AC = 4 * NUM
        ADD TMP       / AC = 6 * NUM
        ADD TMP       / AC = 8 * NUM
        ADD TMP       / AC = 10 * NUM
        
        / Add the isolated single digit to your base total running value
        ADD DIGIT     / AC = (10 * NUM) + DIGIT
        STA NUM       / Save accumulated value back to NUM
        BUN IN_LP     / Loop back silently for the next input character

/ --- Step 2: Factorial Calculation Engine ---
EXP_START,
        LDA C_1
        STA FACT      / Initialize FACT = 1
        LDA NUM
        STA M         / Initialize multiplier M = NUM

FACT_LP,
        LDA M
        SZA           / Check if multiplier M has hit 0
        BUN DO_MULT   / If M != 0, perform the nested multiplication step
        BUN PRINT_TXT / If M == 0, factorial computation is complete!

DO_MULT,
        LDA C_0
        STA PRODUCT   / Clear product buffer before starting additions
        
        / Set up inner loop counter: CTR_INNER = -M
        LDA M
        CMA
        INC           / AC = -M
        STA CTR_INNER

MULT_LP,
        LDA PRODUCT
        ADD FACT
        STA PRODUCT   / PRODUCT = PRODUCT + FACT
        ISZ CTR_INNER / Increment loop counter
        BUN MULT_LP   / Repeat loop M times
        
        / Save the product as the new base factorial value
        LDA PRODUCT
        STA FACT
        
        / Decrement the multiplier: M = M - 1
        LDA M
        ADD M_1
        STA M
        BUN FACT_LP   / Loop back for next factorial multiplication level

/ --- Step 3: Clear TTY Screen & 5-Digit Integer Deconstruction ---
PRINT_TXT,
W_CLR,  SKO           / Wait for TTY output line buffer to clear
        BUN W_CLR
        LDA C_12      / Load Form Feed ASCII control character (12 / 0x0C)
        OUT           / Send Form Feed command to instantly clear TTY display panel

        / Copy final factorial answer into workspace variable
        LDA FACT
        STA RES

        / Initialize digit counter registers to 0
        LDA C_0
        STA T_THOU
        STA THOU
        STA HUNDREDS
        STA TENS

/ Extract Ten-Thousands Column
TT_LP,  LDA RES
        ADD M_10000   / Subtract 10,000
        SNA           / Skip next branch if AC went negative (RES < 10000)
        BUN TT_OK
        BUN TH_START  / Negative! Ten-thousands place extraction complete
TT_OK,  STA RES       / Save updated remainder
        ISZ T_THOU    / Increment ten-thousands place counter
        BUN TT_LP

/ Extract Thousands Column
TH_START,
TH_LP,  LDA RES
        ADD M_1000    / Subtract 1,000
        SNA           / Skip next branch if AC went negative (RES < 1000)
        BUN TH_OK
        BUN H_START   / Negative! Thousands place extraction complete
TH_OK,  STA RES       / Save updated remainder
        ISZ THOU      / Increment thousands place counter
        BUN TH_LP

/ Extract Hundreds Column
H_START,
H_LP,   LDA RES
        ADD M_100     / Subtract 100
        SNA           / Skip next branch if AC went negative (RES < 100)
        BUN H_OK
        BUN T_START   / Negative! Hundreds place extraction complete
H_OK,   STA RES       / Save updated remainder
        ISZ HUNDREDS  / Increment hundreds place counter
        BUN H_LP

/ Extract Tens Column
T_START,
T_LP,   LDA RES
        ADD M_10_VAL  / Subtract 10
        SNA           / Skip next branch if AC went negative (RES < 10)
        BUN T_OK
        BUN PR_START  / Negative! Tens place extraction complete
T_OK,   STA RES       / Save updated remainder
        ISZ TENS      / Increment tens place counter
        BUN T_LP

/ --- Step 4: Text Streaming & Leading Zero Suppression ---
PR_START,
        LDA C_0
        STA P_FLAG    / Clear print activation flag (0 = suppressing zeros)

    / Evaluate Ten-Thousands Place
        LDA T_THOU
        SZA
        BUN PR_TT
        BUN CHK_TH    / It's a leading zero, check next column
PR_TT,  ADD C_48      / Convert integer to ASCII
        STA CHAR
W_TT,   SKO
        BUN W_TT
        LDA CHAR
        OUT           / Print Ten-Thousands digit
        LDA C_1
        STA P_FLAG    / Turn on print flag (unblocks trailing zeros)

    / Evaluate Thousands Place
CHK_TH, LDA THOU
        SZA
        BUN PR_TH
        LDA P_FLAG    / Check if previous column printed anything
        SZA
        BUN PR_TH
        BUN CHK_H     / Suppress zero
PR_TH,  LDA THOU
        ADD C_48
        STA CHAR
W_TH,   SKO
        BUN W_TH
        LDA CHAR
        OUT           / Print Thousands digit
        LDA C_1
        STA P_FLAG

    / Evaluate Hundreds Place
CHK_H,  LDA HUNDREDS
        SZA
        BUN PR_H
        LDA P_FLAG
        SZA
        BUN PR_H
        BUN CHK_T     / Suppress zero
PR_H,   LDA HUNDREDS
        ADD C_48
        STA CHAR
W_H,    SKO
        BUN W_H
        LDA CHAR
        OUT           / Print Hundreds digit
        LDA C_1
        STA P_FLAG

    / Evaluate Tens Place
CHK_T,  LDA TENS
        SZA
        BUN PR_T
        LDA P_FLAG
        SZA
        BUN PR_T
        BUN PR_UN     / Suppress zero
PR_T,   LDA TENS
        ADD C_48
        STA CHAR
W_T,    SKO
        BUN W_T
        LDA CHAR
        OUT           / Print Tens digit

    / Evaluate Units Place (Always Prints)
PR_UN,  LDA RES
        ADD C_48
        STA CHAR
W_U,    SKO
        BUN W_U
        LDA CHAR
        OUT           / Print Units digit

        / --- RE-ENTRY JUMP ---
        BUN START     / Loop back cleanly to accept the next interactive user input

/ --- Step 5: Termination Escape Handler ---
HALT_PROG,
        HLT           / Hard halt execution when a period ('.') is typed

/ --- Storage & Variables Segment ---
NUM,       HEX 0
CHAR,      HEX 0
DIGIT,     HEX 0
TMP,       HEX 0
M,         HEX 0         / Multiplier tracking register
FACT,      HEX 0         / Factorial base running result
PRODUCT,   HEX 0         / Multiplication math accumulator
CTR_INNER, HEX 0         / Multiplication loop counter
RES,       HEX 0         / Remainder base variable during digit splits
T_THOU,    HEX 0
THOU,      HEX 0
HUNDREDS,  HEX 0
TENS,      HEX 0
P_FLAG,    HEX 0         / Formatting state register

/ --- Constants Segment ---
C_0,       DEC 0
C_1,       DEC 1
C_12,      DEC 12        / Form Feed ASCII constant to clear the TTY display
C_48,      DEC 48
M_1,       DEC -1        / Down-counter modifier constant
M_10,      DEC -10
M_13,      DEC -13
M_46,      DEC -46       / Used to filter for exit character ('.')
M_48,      DEC -48
M_10000,   DEC -10000    / 2's complement negative literal values
M_1000,    DEC -1000
M_100,     DEC -100
M_10_VAL,  DEC -10
END