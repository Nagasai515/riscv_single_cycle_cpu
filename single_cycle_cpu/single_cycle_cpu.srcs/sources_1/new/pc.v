`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2025 22:02:39
// Design Name: 
// Module Name: pc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc(input clk,
input reset,
output reg [31:0]pc_out
    );
    always@(posedge clk or posedge reset)
    begin
    if(reset)
    pc_out<=0;
    else
    pc_out<=pc_out+4;
    end
endmodule
