`timescale 1ns / 1ps

module instruction_memory (
    input  [31:0] addr,     // Program Counter address
    output [31:0] instr     // Fetched instruction
);

    reg [31:0] memory [0:255];   // 1 KB Instruction ROM (256 x 32-bit)

    // Load instructions from program.mem file
    initial begin
        $readmemh("program.mem", memory);
    end

    // Word addressing: instruction index = PC[31:2]
    assign instr = memory[addr[31:2]];

endmodule
