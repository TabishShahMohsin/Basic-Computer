/ A simple program to add two numbers
ORG 0
START,  LDA NUM1   / Load first number into AC
        ADD NUM2   / Add second number to AC
        STA RESULT / Store the sum
        HLT        / Halt execution
NUM1,   DEC 25     / Store decimal 25
NUM2,   DEC -5     / Store decimal -5
RESULT, HEX 0      / Room for the result
END