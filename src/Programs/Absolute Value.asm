/ Absolute of a Number
ORG 10                  / Starting from 0x0010
START,  LDA NUM1        / Store NUM 1
        SNA             / Jump through negation logic if positive
        BUN POS          
        CMA             
        INC
POS,    STA RESULT      / Storing the result
        HLT

NUM1, DEC -25
RESULT, DEC 0
END
