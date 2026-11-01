`timescale 1ns / 1ps

module main_control (
    input  logic [6:0] opcode,
    input  logic [2:0] fn3,
    output logic [1:0] memtoreg,    // write-back select
    output logic       branch,
    output logic       mux_inp,     // 1 = JALR (target comes from the ALU)
    output logic       memread,
    output logic       memwrite,
    output logic       alusrc,      // 0 = rs2, 1 = immediate
    output logic       reg_write,
    output logic [2:0] aluop        // operation class for the ALU control
);

    always_comb begin
        case (opcode)
            7'b0110011: begin // R-type
                memtoreg  = 2'b00;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b0;
                reg_write = 1'b1;
                aluop     = 3'b000;
            end
            7'b0010011: begin // I-type ALU
                memtoreg  = 2'b00;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b001;
            end
            7'b0000011: begin // Load
                memtoreg  = 2'b01;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b1;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b010;
            end
            7'b0100011: begin // Store
                memtoreg  = 2'b11;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b1;
                alusrc    = 1'b1;
                reg_write = 1'b0;
                aluop     = 3'b011;
            end
            7'b1100011: begin // Branch
                memtoreg  = 2'b00;
                branch    = 1'b1;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b0;
                reg_write = 1'b0;
                aluop     = 3'b100;
            end
            7'b1101111: begin // JAL
                memtoreg  = 2'b10;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b110;
            end
            7'b1100111: begin // JALR
                memtoreg  = 2'b10;
                branch    = 1'b0;
                mux_inp   = 1'b1;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b001;
            end
            7'b0110111: begin // LUI
                memtoreg  = 2'b10;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b110;
            end
            7'b0010111: begin // AUIPC
                memtoreg  = 2'b10;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b000;
            end
            default: begin // Other
                memtoreg  = 2'b00;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b0;
                reg_write = 1'b0;
                aluop     = 3'b000;
            end
        endcase
    end

endmodule
