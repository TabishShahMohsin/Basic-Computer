/ =================================================================
/ Continuous Base-10 Fibonacci Program with TTY Clear Function
/ Input: Type decimal digits (e.g., '1' '2' Enter) -> Prints '89'
/ Next Input: Type another digit (e.g., '5' Enter) -> Clears screen, prints '3'
/ Exit Condition: Type '.' at any time to halt the simulation execution
/ =================================================================

ORG 0
START,  LDA C_0
        STA NUM       / Reset accumulated input number back to 0 for a fresh cycle

/ --- Step 1: Character Input & Exit Character Parsing Loop ---
IN_LP,  SKI           / Poll Input Flag (FGI) until a key is pressed
        BUN IN_LP
        INP           / AC(0-7) <- INPR (High bits are hardware grounded)
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
        BUN EXP_START / It was LF! Proceed to calculations
        
NOT_LF, LDA CHAR
        ADD M_13      / Check if Enter Key was a Carriage Return (CR = 13)
        SZA
        BUN PROCESS   / Not Enter -> Validated as a normal numeric digit character
        BUN EXP_START / It was CR! Proceed to calculations

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

/ --- Step 2: Fibonacci Calculation Engine ---
EXP_START,
        / Set up loop counter: CTR = 2 - NUM
        / For Input 12, CTR becomes 2 - 12 = -10 (Loops exactly 10 times)
        / For Input 5, CTR becomes 2 - 5 = -3 (Loops exactly 3 times)
        LDA NUM
        CMA
        INC           / AC = -NUM
        ADD C_2       / AC = 2 - NUM
        STA CTR

        / Initialize Fibonacci sequence bases (F0 = 0, F1 = 1)
        LDA C_0
        STA F0
        LDA C_1
        STA F1

FIB_LP,
        LDA F0
        ADD F1
        STA F2        / F2 = F0 + F1
        LDA F1
        STA F0        / Shift sequence: F0 = F1
        LDA F2
        STA F1        / Shift sequence: F1 = F2
        ISZ CTR       / Increment loop counter
        BUN FIB_LP    / Loop until CTR increments to 0

        / Save calculated sequence result for text conversion processing
        LDA F1
        STA RES       / Holds final sequence total (e.g., 89 or 3)

/ --- Step 3: Clear TTY Screen & Base-10 Integer Deconstruction ---
PRINT_TEXT,
W_CLR,  SKO           / Wait for TTY output line buffer to clear
        BUN W_CLR
        LDA C_12      / Load Form Feed ASCII control character (12 / 0x0C)
        OUT           / Send Form Feed command to instantly clear TTY display panel

        LDA C_0
        STA HUNDREDS  / Reset Hundreds place counter
        STA TENS      / Reset Tens place counter

/ Extract Hundreds Digit Column
H_LOOP,
        LDA RES
        ADD M_100     / Subtract 100
        SNA           / Skip next branch if AC went negative (RES < 100)
        BUN H_OK
        BUN T_START   / Negative! Hundreds place extraction complete
H_OK,
        STA RES       / Save updated remainder
        ISZ HUNDREDS  / Increment hundreds place counter
        BUN H_LOOP

/ Extract Tens Digit Column
T_START,
T_LOOP,
        LDA RES
        ADD M_10_VAL  / Subtract 10
        SNA           / Skip next branch if AC went negative (RES < 10)
        BUN T_OK
        BUN PR_START  / Negative! Tens place extraction complete
T_OK,
        STA RES       / Save updated remainder
        ISZ TENS      / Increment tens place counter
        BUN T_LOOP

/ --- Step 4: Text Streaming & Leading Zero Suppression ---
PR_START,
        / Evaluate Hundreds place
        LDA HUNDREDS
        SZA           / If Hundreds column is 0, skip printing it
        BUN DO_HUND
        BUN DO_TENS_HO/ Hundreds is 0, evaluate Tens column conditionally

DO_HUND,
        ADD C_48      / Convert Hundreds integer digit back to ASCII
        STA CHAR
W_H,    SKO
        BUN W_H
        LDA CHAR
        OUT           / Print Hundreds digit character
        
        / If Hundreds was printed, Tens MUST print (even if Tens is 0)
        LDA TENS
        ADD C_48
        STA CHAR
W_T1,   SKO
        BUN W_T1
        LDA CHAR
        OUT           / Print Tens digit character
        BUN DO_UNITS  / Jump to units execution block

DO_TENS_HO,
        / Hundreds was 0, so only print Tens if Tens > 0
        LDA TENS
        SZA           / If Tens column is 0, skip to Units (avoids printing "03")
        BUN DO_TENS_ONLY
        BUN DO_UNITS

DO_TENS_ONLY,
        ADD C_48      / Convert Tens integer digit back to ASCII
        STA CHAR
W_T2,   SKO
        BUN W_T2
        LDA CHAR
        OUT           / Print Tens digit character

DO_UNITS,
        / Units place (remaining value in RES) always prints
        LDA RES
        ADD C_48      / Convert Units integer digit back to ASCII
        STA CHAR
W_U,    SKO
        BUN W_U
        LDA CHAR
        OUT           / Print Units digit character

        / --- RE-ENTRY JUMP ---
        BUN START     / Loop completely back to clear variables and accept next input

/ --- Step 5: Termination Escape Handler ---
HALT_PROG,
        HLT           / Hard halt execution when a period ('.') is received

/ --- Storage & Variables Segment ---
NUM,       HEX 0
CHAR,      HEX 0
DIGIT,     HEX 0
TMP,       HEX 0
CTR,       HEX 0
F0,        HEX 0
F1,        HEX 0
F2,        HEX 0
RES,       HEX 0
HUNDREDS,  HEX 0
TENS,      HEX 0

/ --- Constants Segment ---
C_0,       DEC 0
C_1,       DEC 1
C_2,       DEC 2
C_12,      DEC 12        / Form Feed (0x0C) control constant used to clear TTY
C_48,      DEC 48
M_10,      DEC -10
M_13,      DEC -13
M_46,      DEC -46       / Used to test for termination character input ('.')
M_48,      DEC -48
M_100,     DEC -100
M_10_VAL,  DEC -10
END