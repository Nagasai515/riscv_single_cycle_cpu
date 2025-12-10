`timescale 1ns / 1ps

//
// RV32I Branch Control Module
// Decides whether a branch or jump should occur
//

module branch_control (
    input        Branch,        // Branch instruction (from Main Control)
    input        Jump,          // JAL or JALR (from Main Control)
    input  [2:0] funct3,        // instr[14:12]
    input        Zero,          // ALU zero flag
    input        slt,           // signed less-than from ALU
    input        sltu,          // unsigned less-than from ALU
    output       PCSrc          // 1 = take branch/jump, 0 = PC+4
);

    reg cond;

    always @(*) begin
        case (funct3)

            3'b000: cond = Zero;          // BEQ
            3'b001: cond = ~Zero;         // BNE
            3'b100: cond = slt;           // BLT (signed)
            3'b101: cond = ~slt;          // BGE (signed)
            3'b110: cond = sltu;          // BLTU (unsigned)
            3'b111: cond = ~sltu;         // BGEU (unsigned)
            default: cond = 1'b0;
        endcase
    end

    // Final PCSrc logic:
    assign PCSrc = Jump | (Branch & cond);

endmodule
