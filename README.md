# Basic-Computer

<p>
  Mano Machine is a 16 Bit computer provided in the books by Morris Mano, which is able to execute simple programs like Fibonacci, Factorial, Bubble Sort and Guess the Number Game. This repository is an implementation of 
  <a href="https://api.amu.ac.in/storage/file/30/under-graduate/syll/1753945183.pdf#page=16" data-fallback="/University/Syllabus.pdf#page=16">Digital Logic and Circuit Design (COC2072)</a>, 
  <a href="https://api.amu.ac.in/storage/file/30/under-graduate/syll/1753945183.pdf#page=30" data-fallback="/University/Syllabus.pdf#page=30">Digital Design & Simulation Lab (COC2922)</a> and 
  <a href="https://api.amu.ac.in/storage/file/30/under-graduate/syll/1753945183.pdf#page=19" data-fallback="/University/Syllabus.pdf#page=19">Computer Architecture (COC2082)</a>.
</p>

---

![Fibonacci](src/Programs/Fibonacci.mov)

* [Decoded Instructions](https://docs.google.com/spreadsheets/d/1iQ1Zzdj7JYTmBiXy1o-t-n2Hny4eIJqiO4zj733_0VQ/edit?usp=sharing)
* Books: 
    * Computer System Architecture - M. Morris Mano
    * Digital Logic and Computer Design - M. Morris Mano
<!-- * Similar project: [computer-8bits](https://github.com/leonicolas/computer-8bits) -->
* Lectures: [Bharat Acharya Education (Intel 8085)](https://www.youtube.com/watch?v=oY_ojcLWm80&list=PLfzBO7vcQZ1JTpio2FEeII_70jzAGh6kx&index=13&t=601s)
* Note: For looped circuits $(Q = f(Q))$, the sim may not be able to find the correct state, hence RESET pin is used to make initial Q as 0 - similar to setting a base case for recursion.
* Logism provides features like getting truth-table, running txt-tests, etc.
* Particulars about the version of Logisim used:
    * Product: Logisim-evolution v4.0.0
    * Runs on: Java HotSpot(TM) 64-Bit Server VM v21.0.4
    * Compiled: 2025-09-07T09:17:48+0200
    * Build ID: main/00b4b30e
    * Built on: Java HotSpot(TM) 64-Bit Server VM v21.0.4
* We may create Memory from scratch as well, but logisim allows us to load programs using Hex files.
* This repo was made such that everything feels very accessible, however logisim doesn't allow a library to be used if it was used in an already imported library. So if you are trying to re-create this probably should make everything in a single file with different circuits. Or forcefully import by writing the import statement in the .circ file.
* A picture is worth a thousand gates.
* Pin order in logisim of the imported circuit depends on the build circuit.
* This project can be later extended to make the processor for [Apple 1](http://visual6502.org/).
* If you find any issues, inconsistencies in notation, some logical flaw, or anything worth mentioning, please let me know. Pull requests are always welcomed.
* Computer Specifics: Von Neumann Architecture, Accumulator-Based (Leaning toward CISC), Hardwired Control Unit, Isolated I/O, Fixed-Length Instructions, 4K Words (8KB RAM), SISD (Single Instruction Single Data), falling-edge triggering


## How to Run
1. Ensure you have [Logisim-evolution v4.0.0+](https://github.com/logisim-evolution/logisim-evolution) installed.
2. Clone this repo.
3. Open `src/04-datapath/BasicComputer.circ`.
4. To run a program: Right-click the RAM component -> **Load Image** -> Select your `.hex` file.
5. Press `Ctrl + K` to start the execution.


## Structure:
```text
├── .gitignore
├── README.md
└── src/
|    ├── 00-Digital Logic Combinational and Sequential Circuits/    
|    │   ├── HalfAdder.circ
|    │   ├── FullAdder.circ
|    │   ├── 4BitAdder.circ
|    │   ├── 16BitAdder.circ
|    │   ├── MUX_2x1.circ         
|    │   ├── MUX_4x1.circ         
|    │   ├── MUX_8x1.circ         # Crucial: 16 of these make the Common Bus
|    │   ├── Decoder_2x4.circ
|    │   ├── Decoder_3x8.circ     # Used in Control Unit for opcodes (D0-D7)
|    │   ├── Decoder_4x16.circ    # Used in Control Unit for timing (T0-T15)
|    │   ├── D_FlipFlop.circ
|    │   ├── JK_FlipFlop.circ
|    │   ├── T_FlipFlop.circ
|    │   ├── Register_8bit.circ   # For INPR and OUTR
|    │   ├── Register_12bit.circ  # For AR and PC
|    │   ├── Register_16bit.circ  # For DR, AC, IR, and TR
|    │   ├── FlipFlop_E.circ      # Extended AC bit (E flip-flop)
|    │   ├── FlipFlop_I.circ      # Interrupt flip-flop (IEN)
|    │   ├── FlipFlop_R.circ      # Interrupt cycle flip-flop (R)
|    │   ├── FlipFlop_S.circ      # Start/Stop flip-flop (S)
|    │   └── SequenceCounter.circ # 4-bit counter (SC) with Increment, Clear, Clock
|    │
|    ├── 01-alu/              # Arithmetic Logic Shift Unit (ALSU)
|    │   ├── ArithmeticCircuit.circ # Performs Add, Sub, Increment, Decrement
|    │   ├── LogicCircuit.circ      # Performs AND, ADD, LDA, CMA, CIR, CIL
|    │   ├── ShiftCircuit.circ      # Handles shift-right (shr) and shift-left (shl)
|    │   └── ALSU_16bit.circ        # Combines Arithmetic, Logic, and Shift into one unit
|    │
|    ├── 02-memory/           # Main Memory (RAM)
|    │   └── RAM_4096x16.circ     # Usually wraps Logisim's built-in RAM with Mano's Read/Write pins
|    │
|    ├── 03-control-unit/     # The "brain" decoding instructions and timing
|    │   ├── InstructionDecoder.circ# Splits IR into I-bit, Opcode (3-bit), Address (12-bit)
|    │   ├── TimingGenerator.circ   # Wires the SC to the 4x16 Decoder yielding T0-T15
|    │   ├── ControlGates_AR.circ   # Computes Load, Inc, Clr for AR (e.g., LD_AR = R'T0 + R'T2 + ...)
|    │   ├── ControlGates_PC.circ   # Computes Load, Inc, Clr for PC
|    │   ├── ControlGates_DR.circ   # Computes Load, Inc, Clr for DR
|    │   ├── ControlGates_AC.circ   # Computes Load, Inc, Clr for AC
|    │   ├── ControlGates_IR.circ   # Computes Load for IR
|    │   ├── ControlGates_TR.circ   # Computes Load, Inc, Clr for TR
|    │   ├── ControlGates_Mem.circ  # Computes Read and Write signals for RAM
|    │   └── MainControlUnit.circ   # Assembles all control logic into one massive block
|    │
|    └── 04-datapath/         # Final integration
|        ├── CommonBus.circ         # Wires the registers and memory to the 8x1 Multiplexers
|        └── BasicComputer.circ     # The main file: Instantiates CommonBus, ALSU, and MainControlUnit
| 
└── University/
     ├── Computer Architecture/    # Building the computer from basic DLSD circuits
     │   └── Computer Architecture.pdf 
     ├── Digital Logic and System Design/    # Building sequential and combinational circuits
     │   ├── Unit I.pdf 
     │   ├── Unit II.pdf 
     │   ├── Unit III.pdf 
     └   └── Unit IV.pdf 
```
