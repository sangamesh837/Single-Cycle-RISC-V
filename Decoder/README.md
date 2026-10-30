# Decoder

Design the instruction field decoder. It splits a 32-bit instruction into its fields depending on the opcode.

### Module Specification

```SystemVerilog
`timescale 1ns / 1ps

module decoder(
    input  logic [31:0] instruction,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [6:0]  opcode,
    output logic [6:0]  imm11_5,      // instruction[31:25] (I-type ALU only)
    output logic [2:0]  fn3,
    output logic [11:0] imm,          // I / S / B immediate bits
    output logic [19:0] imm_uj,       // U / J immediate bits
    output logic        fn7_5         // instruction[30] (R-type only)
);

    assign opcode = instruction[6:0];

    always_comb begin
        // Default values to 0
        rs1     = 5'd0;
        rs2     = 5'd0;
        rd      = 5'd0;
        imm11_5 = 7'd0;
        fn3     = 3'd0;
        imm     = 12'd0;
        imm_uj  = 20'd0;
        fn7_5   = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                rd    = instruction[11:7];
                fn3   = instruction[14:12];
                rs1   = instruction[19:15];
                rs2   = instruction[24:20];
                fn7_5 = instruction[30];
            end
            7'b0010011: begin // I-type ALU
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
                imm11_5 = instruction[31:25];
            end
            7'b0000011: begin // Load
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end
            7'b0100011: begin // Store
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin // Branch
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
            end
            7'b1101111: begin // JAL
                rd     = instruction[11:7];
                imm_uj = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
            end
            7'b1100111: begin // JALR
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end
            7'b0110111: begin // LUI
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end
            7'b0010111: begin // AUIPC
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end
            default: begin
                // All outputs remain 0
            end
        endcase
    end

endmodule
```

### Working

`opcode = instruction[6:0]` always. Every other output is **0 unless the opcode below uses it**:

| Opcode | Instruction | Fields produced |
|---|---|---|
| `0110011` | R-type | `rd` `fn3` `rs1` `rs2` `fn7_5 = instruction[30]` |
| `0010011` | I-type ALU | `rd` `fn3` `rs1` `imm = instruction[31:20]` `imm11_5 = instruction[31:25]` |
| `0000011` | Load | `rd` `fn3` `rs1` `imm = instruction[31:20]` |
| `0100011` | Store | `fn3` `rs1` `rs2` `imm = {instruction[31:25], instruction[11:7]}` |
| `1100011` | Branch | `fn3` `rs1` `rs2` `imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}` |
| `1101111` | JAL | `rd` `imm_uj = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]}` |
| `1100111` | JALR | `rd` `fn3` `rs1` `imm = instruction[31:20]` |
| `0110111` | LUI | `rd` `imm_uj = instruction[31:12]` |
| `0010111` | AUIPC | `rd` `imm_uj = instruction[31:12]` |
| other | unsupported | everything except `opcode` is 0 |

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
