`timescale 1ns / 1ps
//
// RV32I Arithmetic Logic Unit (ALU)
// Supports all R-type and I-type ALU operations
//

module arithmetic_logic_unit(
    input  [31:0] a,           // Operand A (from rs1)
    input  [31:0] b,           // Operand B (from rs2 or immediate)
    input  [3:0]  alu_ctrl,    // ALU control signal (from ALU Control Unit)
    output reg [31:0] result,  // ALU result
    output        zero         // Zero flag (used by BEQ/BNE)
);

    always @(*) begin
        case (alu_ctrl)

            4'b0000: result = a + b;                         // ADD
            4'b0001: result = a - b;                         // SUB

            4'b0010: result = a & b;                         // AND
            4'b0011: result = a | b;                         // OR
            4'b0100: result = a ^ b;                         // XOR

            4'b0101: result = a << b[4:0];                   // SLL  (shift left logical)
            4'b0110: result = a >> b[4:0];                   // SRL  (shift right logical)
            4'b0111: result = $signed(a) >>> b[4:0];         // SRA  (shift right arithmetic)

            4'b1000: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT  (signed compare)
            4'b1001: result = (a < b) ? 1 : 0;                // SLTU (unsigned compare)

            default:  result = 0;

        endcase
    end

    // Zero flag: used for branch decisions (BEQ/BNE)
    assign zero = (result == 0);

endmodule
