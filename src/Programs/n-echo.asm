/ To echo what is inputed n times char by char


/ Saved Return Address
ORG 0
RES_ADDR,       BUN START       / Band-Aid for it not shooting to ISR directly
                BUN ISR 
        

/ Main Program (Infinite Loop after Negation of N)
ORG 10     
START, 
        LDA N
        CMA
        INC
        STA N
        ION
MAIN_LP,
        BUN MAIN_LP


/ Interrupt Service Routine
ISR,
        LDA N
        STA J
        INP
        PRINT_LP,
                W_OUT,
                        SKO
                        BUN W_OUT
                OUT
                ISZ J
                BUN PRINT_LP
        ION
        BUN RES_ADDR I

N, DEC 5
J, DEC 0
END
