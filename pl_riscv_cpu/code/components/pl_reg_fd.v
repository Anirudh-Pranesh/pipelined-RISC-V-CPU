
/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         pl_reg_fd.v
# File Description: transfers instruction and PC data from fetch to decode
# Global variables: clk, reset, en, clr, InstrF, PCF, PCPlus4F, InstrD, PCD, PCPlus4D
*/

// pipeline registers -> fetch | decode stage

module pl_reg_fd (
    // clk: clock signal
    // reset: reset signal to clear the register
    // en: enables values to be stored in the register
    // clr: clears the register to insert a bubble
    input             clk, reset, en, clr,
    // InstrF: instruction from fetch stage
    // PCF: program counter for fetch stage
    // PCPlus4F: PC plus four for fetch stage instruction
    input      [31:0] InstrF, PCF, PCPlus4F,
    // InstrD: instruction held in decode stage
    // PCD: program counter for decode stage
    // PCPlus4D: PC plus four for decode stage instruction
    output reg [31:0] InstrD, PCD, PCPlus4D
);

initial begin
    /*
    Purpose:
    ---
    initialises the IF/ID register outputs to zero before instruction fetch begins
    */

    InstrD = 0; PCD = 0; PCPlus4D = 0;
end

always @(posedge clk) begin
    /*
    Purpose:
    ---
    transfers the fetched instruction and its PC values into decode, or holds or clears them as controlled
    */

    if (reset || clr) begin
        InstrD <= 0; PCD <= 0; PCPlus4D <= 0;
    end else if (en) begin
        InstrD <= InstrF; PCD <= PCF;
        PCPlus4D <= PCPlus4F;
    end
end

endmodule
