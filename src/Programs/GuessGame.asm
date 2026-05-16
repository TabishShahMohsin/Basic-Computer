/ =================================================================
/ Interactive "Guess the Number" Game for Mano Basic Computer
/ Secret Number Target: 42
/ Input: Type a decimal number (e.g., '5' '0' Enter)
/ Output: Clears screen, displays hint ("HIGH", "LOW", or "OK")
/ Exit Condition: Type '.' at any time to halt the simulation
/ =================================================================

ORG 0
START,  LDA C_0
        STA NUM       / Reset accumulated guess number back to 0 for a new turn

/ --- Step 1: Character Input & Exit Character Parsing Loop ---
IN_LP,  SKI           / Poll Input Flag (FGI) until a key is pressed
        BUN IN_LP
        INP           / AC(0-7) <- INPR (High bits are hardware grounded to 0)
        STA CHAR      / Save pristine ASCII code

        / Check if the Period Key was pressed ('.' = 46) to terminate program
        ADD M_46      / AC = CHAR - 46
        SZA           / If AC is 0 (it was '.'), skip jump to exit game
        BUN CHK_LF    / Not '.', continue checking for Enter keys
        BUN HALT_PROG / It was '.'! Exit the game and halt the system
        
CHK_LF, LDA CHAR
        ADD M_10      / Check if Enter Key was a Line Feed (LF = 10)
        SZA
        BUN NOT_LF
        BUN COMPARE   / It was LF! Proceed to judge the guess
        
NOT_LF, LDA CHAR
        ADD M_13      / Check if Enter Key was a Carriage Return (CR = 13)
        SZA
        BUN PROCESS   / Not Enter -> Validated as a normal numeric digit character
        BUN COMPARE   / It was CR! Proceed to judge the guess

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
        
        / Add the isolated single digit to your base total running guess value
        ADD DIGIT     / AC = (10 * NUM) + DIGIT
        STA NUM       / Save accumulated value back to NUM
        BUN IN_LP     / Loop back silently for the next digit character

/ --- Step 2: Clear TTY Screen & Compare Guess with Secret Target ---
COMPARE,
W_CLR,  SKO           / Wait for TTY output line buffer to clear
        BUN W_CLR
        LDA C_12      / Load Form Feed ASCII control character (12 / 0x0C)
        OUT           / Send Form Feed command to instantly clear old text hints

        / Calculate Difference: AC = NUM - SECRET
        LDA SECRET
        CMA
        INC           / AC = -SECRET
        ADD NUM       / AC = NUM - SECRET
        
        SZA           / If difference is 0 (Guess == Secret), skip to win handler
        BUN CHK_LOW   / Not equal! Go check if it is high or low
        BUN IS_CORR   / Equal! Player wins the game

CHK_LOW,
        / AC still holds the evaluation copy of (NUM - SECRET)
        SNA           / If difference is negative (Guess < Secret), skip to low handler
        BUN IS_HIGH   / Difference is positive -> Guess is too high!
        BUN IS_LOW    / Difference is negative -> Guess is too low!

/ --- Step 3: Handle Too Low Hint ("LOW") ---
IS_LOW,
W_L1,   SKO
        BUN W_L1
        LDA CH_L
        OUT           / Print 'L'
W_L2,   SKO
        BUN W_L2
        LDA CH_O
        OUT           / Print 'O'
W_L3,   SKO
        BUN W_L3
        LDA CH_W
        OUT           / Print 'W'
        BUN START     / Loop completely back to clear NUM and get next guess

/ --- Step 4: Handle Too High Hint ("HIGH") ---
IS_HIGH,
W_H1,   SKO
        BUN W_H1
        LDA CH_H
        OUT           / Print 'H'
W_H2,   SKO
        BUN W_H2
        LDA CH_I
        OUT           / Print 'I'
W_H3,   SKO
        BUN W_H3
        LDA CH_G
        OUT           / Print 'G'
W_H4,   SKO
        BUN W_H4
        LDA CH_H
        OUT           / Print 'H'
        BUN START     / Loop completely back to clear NUM and get next guess

/ --- Step 5: Handle Correct Match Win Hint ("OK") ---
IS_CORR,
W_C1,   SKO
        BUN W_C1
        LDA CH_O
        OUT           / Print 'O'
W_C2,   SKO
        BUN W_C2
        LDA CH_K
        OUT           / Print 'K'
        HLT           / Game Won! Halt the machine smoothly

/ --- Step 6: Termination Escape Handler ---
HALT_PROG,
        HLT           / Hard halt execution when a period ('.') is typed

/ --- Storage & Variables Segment ---
NUM,       HEX 0         / Stores the compiled active guess value
CHAR,      HEX 0         / Stores the captured raw character
DIGIT,     HEX 0         / Stores the isolated single integer digit
TMP,       HEX 0         / Temporary workspace for math step variables

/ --- ASCII String Characters Constants ---
CH_H,      DEC 72        / 'H'
CH_I,      DEC 73        / 'I'
CH_G,      DEC 71        / 'G'
CH_L,      DEC 76        / 'L'
CH_O,      DEC 79        / 'O'
CH_W,      DEC 87        / 'W'
CH_K,      DEC 75        / 'K'

/ --- Math & Control Constants Segment ---
SECRET,    DEC 42        / <--- CHANGE THIS VALUE TO RESET THE SECRET TARGET
C_0,       DEC 0
C_12,      DEC 12        / Form Feed ASCII control character used to wipe TTY
M_10,      DEC -10
M_13,      DEC -13
M_46,      DEC -46       / Look for termination character input ('.')
M_48,      DEC -48
END