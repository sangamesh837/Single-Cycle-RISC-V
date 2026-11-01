# IF Stage (Instruction Fetch)

Design the instruction-fetch stage: the program counter register and the next-PC selection.

### Module Specification

```SystemVerilog
`timescale 1ns / 1ps

module if_stage (
    input  logic        clk,
    input  logic        reset,              // Asynchronous, active high
    input  logic        stall,              // Hold the PC
    input  logic        and_out,            // 1 = take branch/jump target
    input  logic [31:0] pc_signed_offset,   // Branch / jump target address
    output logic [31:0] address,            // Current PC
    output logic [31:0] pc_new              // PC + 4
);

    assign pc_new = address + 32'd4;

    logic [31:0] next_pc;
    assign next_pc = and_out ? pc_signed_offset : pc_new;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address <= 32'h8000_0000;
        end else if (!stall) begin
            address <= next_pc;
        end
    end

endmodule
```

### Working

- `pc_new = address + 4`.
- Next PC is `pc_signed_offset` when `and_out` is high, otherwise `pc_new`.
- On the rising edge of `clk` the PC register loads the next PC, **unless `stall` is high**, in which case it holds.
- On `reset` (asynchronous, active high) the PC becomes **`32'h8000_0000`**.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
