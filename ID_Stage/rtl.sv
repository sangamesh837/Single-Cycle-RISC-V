`timescale 1ns / 1ps

module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,        // data to write back (from the WB stage)
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);

    logic [4:0]  rs1_wire, rs2_wire, rd_wire;
    logic [11:0] imm_wire;
    logic [19:0] imm_uj_wire;
    logic        raw_reg_write;
    logic        gated_reg_write;

    // 1. Decoder
    decoder u_decoder (
        .instruction (instruction),
        .rs1         (rs1_wire),
        .rs2         (rs2_wire),
        .rd          (rd_wire),
        .opcode      (opcode_out_d),
        .imm11_5     (imm11_5),
        .fn3         (fn3_out_d),
        .imm         (imm_wire),
        .imm_uj      (imm_uj_wire),
        .fn7_5       (fn7_5)
    );

    // 2. Immediate Generator
    imm_generator u_imm_gen (
        .imm_input    (imm_wire),
        .fn3          (fn3_out_d),
        .opcode       (opcode_out_d),
        .imm_input_uj (imm_uj_wire),
        .imm_output   (imm_out)
    );

    // 3. Main Control
    main_control u_main_ctrl (
        .opcode    (opcode_out_d),
        .fn3       (fn3_out_d),
        .memtoreg  (memtoreg),
        .branch    (branch),
        .mux_inp   (mux_inp),
        .memread   (mem_read),
        .memwrite  (mem_write),
        .alusrc    (alu_src),
        .reg_write (raw_reg_write),
        .aluop     (aluop)
    );

    // Register write enable is gated: reg_write && !stall
    assign gated_reg_write = raw_reg_write && (!stall);

    // 4. Register File
    register_file u_reg_file (
        .rs1_sel   (rs1_wire),
        .rs2_sel   (rs2_wire),
        .reg_write (gated_reg_write),
        .clk       (clk),
        .reset     (reset),
        .wb_data   (wb_data),
        .rd_sel    (rd_wire),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

endmodule
