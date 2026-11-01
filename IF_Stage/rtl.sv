`timescale 1ns / 1ps

module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,
    output logic [31:0] address,
    output logic [31:0] pc_new
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
