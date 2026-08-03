/ To echo what is inputed x times

/ Saved Return Address
ORG 0
RES_ADDR,   
            HEX 0
            BUN ISR
        

/ Main Program (Infinite Loop)
ORG 10     
START, 
        ION
MAIN_LP,
        BUN MAIN_LP


/ Interrupt Service Routine
ISR,
        LDA N
        STA I

        INP
        STA X

PRINT_LP,

        LDA X

        W_OUT,
                SKO
                BUN W_OUT
        OUT

        LDA I
        ADD O
        STA I
        SNA
        BUN PRINT_LP

        ION

        BUN RES_ADDR I

N, DEC 5
I, DEC 0
X, HEX 0
O, HEX 0xFFFF
END