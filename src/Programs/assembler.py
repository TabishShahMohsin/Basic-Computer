import sys
import os

def parse_assembler(asm_text):
    # Instruction hex maps based on Mano's ISA
    mri = {
        'AND': 0x0000, 'ADD': 0x1000, 'LDA': 0x2000, 'STA': 0x3000,
        'BUN': 0x4000, 'BSA': 0x5000, 'ISZ': 0x6000
    }
    non_mri = {
        'CLA': 0x7800, 'CLE': 0x7400, 'CMA': 0x7200, 'CME': 0x7100,
        'CIR': 0x7080, 'CIL': 0x7040, 'INC': 0x7020, 'SPA': 0x7010,
        'SNA': 0x7008, 'SZA': 0x7004, 'SZE': 0x7002, 'HLT': 0x7001,
        'INP': 0xF800, 'OUT': 0xF400, 'SKI': 0xF200, 'SKO': 0xF100,
        'ION': 0xF080, 'IOF': 0xF040
    }
    
    lines = asm_text.splitlines()
    
    # Pass 1: Build Symbol Table and track addresses
    symbol_table = {}
    current_address = 0
    parsed_lines = []
    
    for line_num, line in enumerate(lines, 1):
        # Strip comments
        code_part = line
        for comment_char in ['/', ';', '#']:
            if comment_char in code_part:
                code_part = code_part.split(comment_char, 1)[0]
        
        code_part = code_part.strip()
        if not code_part:
            continue
            
        # Check for Label (e.g., "START,")
        label = None
        if ',' in code_part:
            label, code_part = code_part.split(',', 1)
            label = label.strip()
            code_part = code_part.strip()
            if label:
                if label in symbol_table:
                    print(f"Warning line {line_num}: Duplicate label definition '{label}'")
                symbol_table[label] = current_address
                
        tokens = code_part.split()
        if not tokens:
            continue
            
        opcode = tokens[0].upper()
        
        parsed_lines.append({
            'line_num': line_num,
            'address': current_address,
            'opcode': opcode,
            'tokens': tokens,
            'label': label
        })
        
        if opcode == 'ORG':
            if len(tokens) < 2:
                print(f"Error line {line_num}: ORG directive missing address operand")
                sys.exit(1)
            try:
                current_address = int(tokens[1], 16)
            except ValueError:
                print(f"Error line {line_num}: Invalid hexadecimal address for ORG: '{tokens[1]}'")
                sys.exit(1)
            parsed_lines[-1]['address'] = current_address
        elif opcode == 'END':
            break
        else:
            current_address += 1

    # Pass 2: Generate 16-bit machine words
    memory = {}
    max_addr = 0
    
    for item in parsed_lines:
        addr = item['address']
        opcode = item['opcode']
        tokens = item['tokens']
        line_num = item['line_num']
        
        if opcode in ['ORG', 'END']:
            continue
            
        max_addr = max(max_addr, addr)
        word = 0
        
        if opcode in mri:
            base_bin = mri[opcode]
            if len(tokens) < 2:
                print(f"Error line {line_num}: Missing operand for Memory-Reference Instruction '{opcode}'")
                sys.exit(1)
            operand = tokens[1]
            
            # Resolve operand label or literal numeric address
            if operand in symbol_table:
                target_addr = symbol_table[operand]
            else:
                try:
                    target_addr = int(operand, 16)
                except ValueError:
                    print(f"Error line {line_num}: Unresolved symbol or invalid hex address '{operand}'")
                    sys.exit(1)
            
            word = base_bin | (target_addr & 0x0FFF)
            
            # Check for Indirect addressing bit
            if len(tokens) >= 3 and tokens[2].upper() == 'I':
                word |= 0x8000
                
        elif opcode in non_mri:
            word = non_mri[opcode]
                
        elif opcode == 'DEC':
            if len(tokens) < 2:
                print(f"Error line {line_num}: DEC directive missing value")
                sys.exit(1)
            try:
                val = int(tokens[1])
                word = val & 0xFFFF
            except ValueError:
                print(f"Error line {line_num}: Invalid decimal value '{tokens[1]}'")
                sys.exit(1)
                
        elif opcode == 'HEX':
            if len(tokens) < 2:
                print(f"Error line {line_num}: HEX directive missing value")
                sys.exit(1)
            try:
                val = int(tokens[1], 16)
                word = val & 0xFFFF
            except ValueError:
                print(f"Error line {line_num}: Invalid hexadecimal value '{tokens[1]}'")
                sys.exit(1)
                
        else:
            print(f"Error line {line_num}: Unknown opcode/instruction '{opcode}'")
            sys.exit(1)
            
        memory[addr] = word
        
    # Format for Logisim RAM image format (v2.0 raw)
    output = ["v2.0 raw"]
    for a in range(max_addr + 1):
        val = memory.get(a, 0)
        output.append(f"{val:04X}")
        
    return "\n".join(output)

def main():
    if len(sys.argv) < 2:
        print("Mano Basic Computer Assembler for Logisim")
        print("Usage: python mano_assembler.py <input_file.asm> [output_file.hex]")
        sys.exit(1)
        
    infile = sys.argv[1]
    if len(sys.argv) >= 3:
        outfile = sys.argv[2]
    else:
        base, _ = os.path.splitext(infile)
        outfile = base + ".hex"
        
    if not os.path.exists(infile):
        print(f"Error: Input file '{infile}' not found.")
        sys.exit(1)
        
    with open(infile, 'r') as f:
        asm_text = f.read()
        
    print(f"Assembling {infile}...")
    hex_output = parse_assembler(asm_text)
    
    with open(outfile, 'w') as f:
        f.write(hex_output + "\n")
        
    print(f"Successfully assembled! Output written to: {outfile}")

if __name__ == '__main__':
    main()