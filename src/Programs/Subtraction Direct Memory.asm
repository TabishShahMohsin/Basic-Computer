/ Subtracting two numbers (A - B)
ORG 10                  / Starting from the 0x0010
START,  LDA NUM2        / Loading the subtrahend B
        CMA             / ~B
        INC             / ~B + 1
        ADD NUM1        / ~B + 1 + A = A - B
        STA RESULT      / Storing the result.
        HLT

NUM1, DEC 25            / Stores the Decimal 25
NUM2, DEC 5             / Stores the Decimal 5
RESULT, DEC 0           / Holds (25 - 5) = 20 (Hex 0014)
END
