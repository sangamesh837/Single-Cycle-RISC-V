`timescale 1ns / 1ps

module alu_control (
    input  logic [2:0] alu_op,        // operation class from main_control
    input  logic [2:0] fn3,
    input  logic [6:0] imm11_5,       // instruction[31:25]: shift qualifier (I-type)
    input  logic       fn7_5,         // instruction[30]: SUB / SRA qualifier (R-type)
    output logic [4:0] control_out
);

    always_comb begin
        case (alu_op)
            3'b000: begin // R-type
                case (fn3)
                    3'b000: control_out = fn7_5 ? 5'b00001 : 5'b00000; // SUB : ADD
                    3'b001: control_out = 5'b00101;                   // SLL
                    3'b010: control_out = 5'b01000;                   // SLT
                    3'b011: control_out = 5'b01001;                   // SLTU
                    3'b100: control_out = 5'b00010;                   // XOR
                    3'b101: control_out = fn7_5 ? 5'b00111 : 5'b00110; // SRA : SRL
                    3'b110: control_out = 5'b00011;                   // OR
                    3'b111: control_out = 5'b00100;                   // AND
                    default: control_out = 5'b00000;
                endcase
            end
            3'b001: begin // I-type ALU
                case (fn3)
                    3'b000: control_out = 5'b00000;                   // ADD (ADDI)
                    3'b001: control_out = 5'b00101;                   // SLL (SLLI)
                    3'b010: control_out = 5'b01000;                   // SLT (SLTI)
                    3'b011: control_out = 5'b01001;                   // SLTU (SLTIU)
                    3'b100: control_out = 5'b00010;                   // XOR (XORI)
                    3'b101: control_out = (imm11_5 == 7'h20) ? 5'b00111 : 5'b00110; // SRAI : SRLI
                    3'b110: control_out = 5'b00011;                   // OR (ORI)
                    3'b111: control_out = 5'b00100;                   // AND (ANDI)
                    default: control_out = 5'b00000;
                endcase
            end
            3'b010: begin // Load
                control_out = 5'b00000; // ADD
            end
            3'b011: begin // Store
                control_out = 5'b00000; // ADD
            end
            3'b100: begin // Branch
                case (fn3)
                    3'b000: control_out = 5'b01010; // BEQ
                    3'b001: control_out = 5'b01011; // BNE
                    3'b100: control_out = 5'b01100; // BLT
                    3'b101: control_out = 5'b01101; // BGE
                    3'b110: control_out = 5'b01110; // BLTU
                    3'b111: control_out = 5'b01111; // BGEU
                    default: control_out = 5'b00000; // other fn3: ADD
                endcase
            end
            3'b110: begin // JAL / LUI
                control_out = 5'b00000; // ADD
            end
            default: begin // other
                control_out = 5'b00000; // ADD
            end
        endcase
    end

endmodule
