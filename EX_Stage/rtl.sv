`timescale 1ns / 1ps

module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,       // current PC
    input  logic        branch,
    input  logic        alu_src,       // 0 = rs2_data, 1 = imm_out
    input  logic        fn7_5,
    input  logic        mux_inp,       // 1 = JALR
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,    // branch / jump taken
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out      // branch / jump target
);

    logic [4:0]  alu_control_sig;
    logic [31:0] operand_b;
    logic        zero;
    logic [31:0] pc_signed_offset;

    // ALU operand B mux
    assign operand_b = alu_src ? imm_out : rs2_data;

    // ALU Control instance
    alu_control u_alu_control (
        .alu_op      (aluop),
        .fn3         (fn3),
        .imm11_5     (imm11_5),
        .fn7_5       (fn7_5),
        .control_out (alu_control_sig)
    );

    // ALU instance
    alu #(.DATA_WIDTH(32)) u_alu (
        .alu_control (alu_control_sig),
        .rs1_data    (rs1_data),
        .rs2_data    (operand_b),
        .alu_out     (alu_out),
        .zero        (zero)
    );

    // PC target calculation
    assign pc_signed_offset = address + imm_out;
    assign pc_ex_out = mux_inp ? {alu_out[31:1], 1'b0} : pc_signed_offset;

    // Branch / jump taken logic
    assign and_out_ex = (branch && zero) || (opcode == 7'h6F) || (opcode == 7'h67);

endmodule
