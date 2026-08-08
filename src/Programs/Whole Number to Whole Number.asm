/ A whole number is entered followed by an Enter
/ that number gets into a single memory slot
/ then that number gets converted back into the same whole number

ORG 0
RETURN, BUN START
        BUN ISR

ORG 10
START,
        ION
IN_LP,
        BUN IN_LP

W_ISR,  ION
        BUN RETURN I

ISR, 
        SKI
        BUN W_ISR

        INP             / AC[0-7] <- INPR, FGI <- 0
        STA DIGIT         

        / Check if Enter is pressed M10/M13 
        ADD M10      
        SZA          
        BUN BNUM        / Add this digit to num
        BUN 10K         / Go to printing phase

BNUM,   LDA NUM
        ADD NUM         / 2 * NUM
        STA NUM
        ADD NUM         / 4 * NUM
        ADD NUM         / 6 * NUM
        ADD NUM         / 8 * NUM
        ADD NUM         / 10 * NUM

        ADD M48         / Conv ascii to value for DIGIT
        ADD DIGIT       / 10 * NUM + DIGIT
        STA NUM

        ION
        BUN RETURN I

10K,
        LDA NUM
        ADD M10K
        SNA
        BUN -10K
        BUN OUT_LP_10K
-10K,   STA NUM
        ISZ D10K
        BUN 10K
OUT_LP_10K,                 
        SKO
        BUN OUT_LP_10K
        LDA D10K
        ADD P48
        OUT

K,
        LDA NUM
        ADD MK
        SNA
        BUN -K
        BUN OUT_LP_K
-K,   STA NUM
        ISZ DK
        BUN K
OUT_LP_K,                 
        SKO
        BUN OUT_LP_K
        LDA DK
        ADD P48
        OUT

100,
        LDA NUM
        ADD M100
        SNA
        BUN -100
        BUN OUT_LP_100
-100,   STA NUM
        ISZ D100
        BUN 100
OUT_LP_100,                 
        SKO
        BUN OUT_LP_100
        LDA D100
        ADD P48
        OUT

10,
        LDA NUM
        ADD M10
        SNA
        BUN -10
        BUN OUT_LP_10
-10,   STA NUM
        ISZ D10
        BUN 10
OUT_LP_10,                 
        SKO
        BUN OUT_LP_10
        LDA D10
        ADD P48
        OUT

1,
        LDA NUM
        ADD M1
        SNA
        BUN -1
        BUN OUT_LP_1
-1,   STA NUM
        ISZ D1
        BUN 1
OUT_LP_1,                 
        SKO
        BUN OUT_LP_1
        LDA D1
        ADD P48
        OUT

        HLT

NUM, DEC 0
DIGIT, HEX 0
M13, DEC -13            / For checking enter
M48, DEC -48            / Converting ASCII num to their values
P48, DEC 48             / Converting digit vals to ASCII 

M1, DEC -1
M10, DEC -10
M100, DEC -100
MK, DEC -1000
M10K, DEC -10000

P1, DEC 1
P10, DEC 10
P100, DEC 100
PK, DEC 1000
P10K, DEC 10000

D1, DEC 0
D10, DEC 0
D100, DEC 0
DK, DEC 0
D10K, DEC 0

END