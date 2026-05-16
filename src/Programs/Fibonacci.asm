/ Base-10 Input Accumulator with Step-by-Step Debug Checkpoints
/ Use this to track exactly what the hardware is processing line by line.

ORG 0
START,  LDA C_0
        STA NUM       / Initialize accumulated number to 0

/ =================================================================
/ CHECKPOINT 1: Catch and display raw keyboard ASCII data
/ =================================================================
IN_LP,  SKI           / Wait for keypress (FGI = 1)
        BUN IN_LP
        INP           / AC(0-7) <- INPR
        AND MASK      / Scrub upper byte residues to isolate ASCII char
        STA CHAR      / Save clean ASCII code

DB_RAW, SKO           / Wait until output channel is clear
        BUN DB_RAW
        LDA CHAR
        OUT           / [TRACE 1]: Flashes the raw ASCII value of the key pressed
                      / Examples: '1' -> 31, '2' -> 32, Enter -> 0D or 0A

        / Check if Enter Key was a Line Feed (LF = 10)
        LDA CHAR
        ADD M_10      / AC = CHAR - 10
        SZA
        BUN NOT_LF
        BUN TRACE_ENT / Found LF! Jump to Enter detection handler
        
NOT_LF, LDA CHAR
        ADD M_13      / Check if Enter Key was a Carriage Return (CR = 13)
        SZA
        BUN PROCESS   / Not Enter -> Validated as a numeric digit character
        BUN TRACE_ENT / Found CR! Jump to Enter detection handler

/ =================================================================
/ CHECKPOINT 2 & 3: Monitor math conversion and multiplication
/ =================================================================
PROCESS,
        LDA CHAR
        ADD M_48      / Subtract 48 to isolate raw integer digit (0-9)
        STA DIGIT

DB_DIG, SKO
        BUN DB_DIG
        LDA DIGIT
        OUT           / [TRACE 2]: Flashes isolated integer digit value
                      / Examples: '1' -> 01, '2' -> 02

        / Multiply NUM by 10 using purely ADD instructions
        LDA NUM
        ADD NUM       / 2 * NUM
        STA TMP
        ADD TMP       / 4 * NUM
        ADD TMP       / 6 * NUM
        ADD TMP       / 8 * NUM
        ADD TMP       / 10 * NUM
        
        ADD DIGIT     / Add the newly parsed digit
        STA NUM       / Update total running value

DB_NUM, SKO
        BUN DB_NUM
        LDA NUM
        OUT           / [TRACE 3]: Flashes current multi-digit total accumulated so far
                      / Examples: After '1' -> 01, After '2' -> 0C (Hex for 12)
                      
        BUN IN_LP     / Jump back to wait for next key

/ =================================================================
/ CHECKPOINT 4: Enter Key caught successfully
/ =================================================================
TRACE_ENT,
        / If execution reaches here, your Enter check worked perfectly!
DB_OK,  SKO
        BUN DB_OK
        LDA C_255     / Load 0xFF marker to signal branch success
        OUT           / [TRACE 4]: Flashes 'FF' indicating Enter was identified

FINAL,  SKO
        BUN FINAL
        LDA NUM
        OUT           / Final output of accumulated hex value
        HLT           / Safe execution halt

/ --- Storage, Variables & Constants Segment ---
NUM,    HEX 0
CHAR,   HEX 0
DIGIT,  HEX 0
TMP,    HEX 0
MASK,   HEX 00FF      / Mask constant to scrub out upper-byte residues
C_0,    DEC 0
C_255,  HEX 00FF      / 255 (0xFF) used as a distinct success flag
M_10,   DEC -10       / Line Feed match check
M_13,   DEC -13       / Carriage Return match check
M_48,   DEC -48       / ASCII digit normalizer
END