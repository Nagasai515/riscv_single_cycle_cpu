module pc (
    input         clk,
    input         reset,
    input  [31:0] pc_next,    // from next PC logic
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 0;
        else
            pc_out <= pc_next;
    end

endmodule
