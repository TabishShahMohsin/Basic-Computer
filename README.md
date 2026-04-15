# Basic-Computer
---
A 16 Bit computer based on the architecture provided in books by Morris Mano, that is able to do simple programs like fibonacci, facotrial, bubble sort and guess the number game. It is an implementation of [DLSD(COC2072)](/University/Syllabus.pdf#page=16) and [Computer Architecture(COC2082)](/University/Syllabus.pdf#page=19).
---
* Similar project and an excellent resource: [comptuer-8bits](https://github.com/leonicolas/computer-8bits)
* Reference books: 
    * Computer System Architecture - M. Morris Mano
    * Digital Logic and Computer Design - M. Morris Mano
* Note: For looped circuits (Q = f(Q)), the sim may not be able to find the correct state, hence RESET pin is used to make inital Q as 0. Same as setting a base case for recursion.
    * Convention: R=1 should reset with Q=0
* Remember Logism provides features like getting truth-table, 
* Particulars about the version of Logisim used:
    * Product: Logisim-evolution v4.0.0
    * Runs on: Java HotSpot(TM) 64-Bit Server VM v21.0.4
    * Compiled: 2025-09-07T09:17:48+0200
    * Build ID: main/00b4b30e
    * Built on: Java HotSpot(TM) 64-Bit Server VM v21.0.4

### Capability:
|Program|Can it do that Right Now?|
|:---|:---|
|Fibonacci(x)|✖️| 
|x!|✖️|
|Bubble Sort|✖️| 
|Guess the Number Game|✖️| 

### Structure:
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
|    │   ├── MUX_8x1.circ         # Crucial: 8 of these make the Common Bus
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
├── University/
|    ├── Computer Architecture/    # Building the computer from basic DLSD circuits
|    │   └── Computer Architecture.pdf 
|    ├── Digital Logic and System Design/    # Building sequential and combinational circuits
|    │   ├── Unit I.pdf 
|    │   ├── Unit II.pdf 
|    │   ├── Unit III.pdf 
|    │   └── Unit IV.pdf 
```


### Logisim Shortcuts: 😅

| Category | Action | Windows / Linux | macOS |
| :--- | :--- | :--- | :--- |
| **Tools** | Poke Tool | `Ctrl` + `1` | `Cmd` + `1` |
| | Edit / Select Tool | `Ctrl` + `2` | `Cmd` + `2` |
| | Text Tool | `Ctrl` + `3` | `Cmd` + `3` |
| **File** | Quit / Exit | `Ctrl` + `Q` | `Cmd` + `Q` |
| **Edit** | Redo | `Ctrl` + `Y` | `Cmd` + `Shift` + `Z` |
| | Duplicate Selection | `Ctrl` + `D` | `Cmd` + `D` |
| **Simulation**| Enable/Disable Simulation | `Ctrl` + `E` | `Cmd` + `E` |
| | Reset Simulation | `Ctrl` + `R` | `Cmd` + `R` |
| | Step Simulation | `Ctrl` + `I` | `Cmd` + `I` |
| | Auto-Tick (Clock) | `Ctrl` + `K` | `Cmd` + `K` |
| | Tick Half Cycle | `Ctrl` + `T` | `Cmd` + `T` |
| **View** | Zoom In | `Ctrl` + `+` | Not working on macOS| 
| | Zoom Out | `Ctrl` + `-` | `Control` + `-` |
| | Reset Zoom / Zoom to Fit | `Ctrl` + `0` | Not working on macOS |
| **Canvas** | Change Component Facing | `Arrow Keys` (↑, ↓, ←, →) | `Arrow Keys` (↑, ↓, ←, →) |
| | Add to Selection | `Shift` + Click | `Shift` + Click |