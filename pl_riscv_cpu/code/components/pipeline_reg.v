/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         pipeline_reg.v
# File Description: register for storing data and control signals between pipeline stages
# Global variables: WIDTH, clk, reset, en, clr, d, q
*/

// pipeline_reg.v - synchronous pipeline register with enable and clear

module pipeline_reg #(parameter WIDTH = 32) (
    // clk: clock signal
    // reset: synchronous reset to clear the register
    // en: enable signal for loading new data
    // clr: clears the register to insert a pipeline bubble
    input                  clk, reset, en, clr,
    // d: data to be stored in the pipeline register
    input      [WIDTH-1:0] d,
    // q: registered output data
    output reg [WIDTH-1:0] q
);

always @(posedge clk) begin
    /*
    Purpose:
    ---
    stores incoming pipeline data on the clock edge, clears it for reset or a bubble, and holds its value when disabled
    */

    if (reset || clr) q <= {WIDTH{1'b0}};
    else if (en)      q <= d;
end

endmodule
