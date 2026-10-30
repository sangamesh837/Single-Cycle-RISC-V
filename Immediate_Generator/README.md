# Immediate Generator

Design the immediate generator. It builds the final 32-bit immediate from the decoder's `imm` / `imm_uj` fields.

### Module Specification

```SystemVerilog
`timescale 1ns / 1ps

module imm_generator(
    input  logic [11:0] imm_input,       // decoder `imm`
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,    // decoder `imm_uj`
    output logic [31:0] imm_output
);

    always_comb begin
        case (opcode)
            7'b1100011: begin // Branch
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};
            end
            7'b1101111: begin // JAL
                imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};
            end
            7'b0110111, 7'b0010111: begin // LUI, AUIPC
                imm_output = {imm_input_uj, 12'b0};
            end
            7'b1100111: begin // JALR
                imm_output = {{20{imm_input[11]}}, imm_input};
            end
            7'b0010011: begin // I-type ALU
                if (fn3 == 3'b001 || fn3 == 3'b101) begin
                    imm_output = {27'b0, imm_input[4:0]};
                end else begin
                    imm_output = {{20{imm_input[11]}}, imm_input};
                end
            end
            default: begin // Load, Store, R-type, anything else
                imm_output = {{20{imm_input[11]}}, imm_input};
            end
        endcase
    end

endmodule
```

### Working

| Opcode | Result |
|---|---|
| Branch `1100011` | `sign_extend(imm_input) << 1` |
| JAL `1101111` | `sign_extend(imm_input_uj) << 1` (20-bit sign extension) |
| LUI `0110111`, AUIPC `0010111` | `{imm_input_uj, 12'b0}` |
| JALR `1100111` | `sign_extend(imm_input)` |
| I-type ALU `0010011` with `fn3 = 001` or `101` (shifts) | `{27'b0, imm_input[4:0]}` |
| I-type ALU `0010011`, other `fn3` | `sign_extend(imm_input)` |
| anything else (load, store, R-type, ...) | `sign_extend(imm_input)` |

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
