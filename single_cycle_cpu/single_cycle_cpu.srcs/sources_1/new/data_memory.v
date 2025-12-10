`timescale 1ns / 1ps

//
// RV32I Data Memory (LW / SW)
// Word-addressed memory, synchronous write, async read
//

module data_memory(
    input         clk,
    input         MemWrite,         // store enable
    input  [31:0] addr,             // byte address from ALU
    input  [31:0] wd,               // write data (rs2)
    output [31:0] rd                // read data (for LW)
);

    // 1 KB data memory: 256 words of 32 bits
    reg [31:0] memory [0:255];

    // WORD addressing: ignore bottom 2 bits
    wire [7:0] index = addr[31:2];

    // READ: asynchronous
    assign rd = memory[index];

    // WRITE: synchronous
    always @(posedge clk) begin
        if (MemWrite)
            memory[index] <= wd;
    end

endmodule
