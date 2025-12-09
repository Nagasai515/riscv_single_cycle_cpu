`timescale 1ns / 1ps

//
// RV32I ALU Control Unit
// Decodes ALUOp + funct3 + funct7[5] into alu_ctrl for the ALU
//

module alu_control (
    input  [1:0] ALUOp,      // From Main Control Unit
    input  [2:0] funct3,     // Instruction[14:12]
    input        funct7b5,   // Instruction[30] = funct7[5] 
    output reg [3:0] alu_ctrl
);

    always @(*) begin
        case (ALUOp)

            // 00 = Load/store (lw, sw) ? ADD
            2'b00: alu_ctrl = 4'b0000;

            // 01 = Branch instructions
            2'b01: begin
                case (funct3)
                    3'b000: alu_ctrl = 4'b0001;  // BEQ ? SUB
                    3'b001: alu_ctrl = 4'b0001;  // BNE ? SUB
                    3'b100: alu_ctrl = 4'b1000;  // BLT ? SLT
                    3'b101: alu_ctrl = 4'b1000;  // BGE ? SLT
                    3'b110: alu_ctrl = 4'b1001;  // BLTU ? SLTU
                    3'b111: alu_ctrl = 4'b1001;  // BGEU ? SLTU
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // 10 = R-type (add, sub, sll, etc.)
            2'b10: begin
                case (funct3)
                    3'b000: alu_ctrl = (funct7b5 ? 4'b0001 : 4'b0000); // SUB if funct7[5]=1 else ADD
                    3'b111: alu_ctrl = 4'b0010; // AND
                    3'b110: alu_ctrl = 4'b0011; // OR   (FIXED)
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b101: alu_ctrl = (funct7b5 ? 4'b0111 : 4'b0110); // SRA / SRL
                    3'b010: alu_ctrl = 4'b1000; // SLT
                    3'b011: alu_ctrl = 4'b1001; // SLTU
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // 11 = I-type ALU (addi, andi, ori, xori, shifts)
            2'b11: begin
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b110: alu_ctrl = 4'b0011; // ORI (same code as OR)
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b101: alu_ctrl = (funct7b5 ? 4'b0111 : 4'b0110); // SRAI / SRLI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    default: alu_ctrl = 4'b0000;
                endcase
            end

        endcase
    end

endmodule
