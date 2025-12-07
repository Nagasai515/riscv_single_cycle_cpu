`timescale 1ns / 1ps

module Register_file(
    input        clk,
    input        we,
    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [4:0] rd,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] regs [0:31];      // 32 registers, each 32-bit

    // Combinational reads
    assign rd1 = regs[rs1];
    assign rd2 = regs[rs2];

    // Sequential write on clock edge
    always @(posedge clk) begin
        if (we && rd != 0) begin 
            regs[rd] <= wd;      // x0 is hardwired to zero
        end
    end

endmodule

