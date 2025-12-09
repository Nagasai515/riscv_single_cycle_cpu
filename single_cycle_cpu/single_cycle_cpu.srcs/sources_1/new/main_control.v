`timescale 1ns / 1ps

//
// RV32I Main Control Unit
// Decodes opcode and generates high-level control signals
//

module main_control(
    input  [6:0] opcode,     // instr[6:0]

    output reg       RegWrite,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       Branch,
    output reg       Jump,
    output reg [1:0] ResultSrc,
    output reg [1:0] ALUOp,
    output reg [2:0] ImmSrc
);

    always @(*) begin
        // Default values (safe)
        RegWrite = 0;
        MemWrite = 0;
        ALUSrc   = 0;
        Branch   = 0;
        Jump     = 0;
        ResultSrc= 2'b00;
        ALUOp    = 2'b00;
        ImmSrc   = 3'b000;

        case (opcode)

            // R-type (add, sub, and, or, shifts...)
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc   = 0;
                ResultSrc= 2'b00; // ALU result
                ALUOp    = 2'b10; // R-type decoded in ALU Control
                ImmSrc   = 3'b000; // unused
            end

            // I-type ALU (addi, xori...)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ResultSrc= 2'b00;
                ALUOp    = 2'b11; // I-type ALU
                ImmSrc   = 3'b000; // I-type immediate
            end

            // Load (lw)
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ResultSrc= 2'b01; // data memory
                ALUOp    = 2'b00; // ADD for address calc
                ImmSrc   = 3'b000; // I-type immediate
            end

            // Store (sw)
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // ADD for address calc
                ImmSrc   = 3'b001; // S-type immediate
            end

            // Branch (beq, bne, blt...)
            7'b1100011: begin
                Branch   = 1;
                ALUSrc   = 0;
                ALUOp    = 2'b01; // branch compare
                ImmSrc   = 3'b010; // B-type immediate
            end

            // JAL
            7'b1101111: begin
                RegWrite = 1;
                Jump     = 1;
                ResultSrc= 2'b10; // PC + 4
                ImmSrc   = 3'b100; // J-type immediate
            end

            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump     = 1;
                ALUSrc   = 1;  // uses immediate for new PC
                ResultSrc= 2'b10;
                ALUOp    = 2'b00; // ADD for PC = rs1 + imm
                ImmSrc   = 3'b000; // I-type immediate
            end

            // LUI
            7'b0110111: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ResultSrc= 2'b00; // write immediate directly
                ImmSrc   = 3'b011; // U-type immediate
                ALUOp    = 2'b00;  // ALU just passes B
            end

            // AUIPC
            7'b0010111: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ResultSrc= 2'b00;
                ImmSrc   = 3'b011; // U-type immediate
                ALUOp    = 2'b00;  // ALU = PC + imm will be done in datapath
            end

        endcase
    end

endmodule
